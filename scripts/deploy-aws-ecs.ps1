# =============================================================================
# Script de Deploy para AWS ECS usando Docker
# Deploy automatizado para Amazon Elastic Container Service
# =============================================================================

param(
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "production",
    
    [string]$Region = "us-east-1",
    [string]$ClusterName = "pipeline-devops-cluster",
    [string]$ServiceName = "pipeline-devops-service",
    [string]$ImageTag = "latest",
    [switch]$CreateInfrastructure = $false,
    [switch]$ForceNewDeployment = $false
)

# Configurações
$ErrorActionPreference = "Stop"
$ProjectName = "devops-pipeline"
$ECRRepository = "pipeline-devops"
$StackName = "pipeline-devops-stack"

Write-Host "🚀 Deploy AWS ECS - $Environment" -ForegroundColor Green
Write-Host "Região: $Region | Cluster: $ClusterName" -ForegroundColor Cyan
Write-Host "=" * 60

# Função para verificar pré-requisitos AWS
function Test-AWSPrerequisites {
    Write-Host "🔍 Verificando pré-requisitos AWS..." -ForegroundColor Cyan
    
    # AWS CLI
    try {
        aws --version | Out-Null
        Write-Host "✅ AWS CLI: OK" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ AWS CLI não encontrado. Instale: https://aws.amazon.com/cli/"
        return $false
    }
    
    # Credenciais AWS
    try {
        $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
        Write-Host "✅ Credenciais AWS: OK ($($identity.UserId))" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Credenciais AWS não configuradas. Execute: aws configure"
        return $false
    }
    
    # Docker
    try {
        docker version | Out-Null
        Write-Host "✅ Docker: OK" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Docker não disponível"
        return $false
    }
    
    return $true
}

# Função para criar infraestrutura com CloudFormation
function Deploy-Infrastructure {
    if (-not $CreateInfrastructure) { return }
    
    Write-Host "🏗️  Criando/Atualizando infraestrutura..." -ForegroundColor Cyan
    
    $templatePath = "iac/iac.yml"
    if (-not (Test-Path $templatePath)) {
        Write-Error "❌ Template CloudFormation não encontrado: $templatePath"
        exit 1
    }
    
    # Verificar se stack existe
    $stackExists = $false
    try {
        aws cloudformation describe-stacks --stack-name $StackName --region $Region | Out-Null
        $stackExists = $true
        Write-Host "📋 Stack existente detectada: $StackName" -ForegroundColor Yellow
    }
    catch {
        Write-Host "📋 Criando nova stack: $StackName" -ForegroundColor Yellow
    }
    
    if ($stackExists) {
        # Atualizar stack existente
        Write-Host "🔄 Atualizando stack..." -ForegroundColor Cyan
        try {
            aws cloudformation update-stack `
                --stack-name $StackName `
                --template-body file://$templatePath `
                --region $Region `
                --capabilities CAPABILITY_IAM
                
            Write-Host "⏳ Aguardando atualização da stack..." -ForegroundColor Yellow
            aws cloudformation wait stack-update-complete --stack-name $StackName --region $Region
        }
        catch {
            if ($_.Exception.Message -like "*No updates are to be performed*") {
                Write-Host "✅ Stack já está atualizada" -ForegroundColor Green
            } else {
                throw
            }
        }
    } else {
        # Criar nova stack
        Write-Host "🏗️  Criando stack..." -ForegroundColor Cyan
        aws cloudformation create-stack `
            --stack-name $StackName `
            --template-body file://$templatePath `
            --region $Region `
            --capabilities CAPABILITY_IAM
            
        Write-Host "⏳ Aguardando criação da stack..." -ForegroundColor Yellow
        aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region
    }
    
    Write-Host "✅ Infraestrutura criada/atualizada!" -ForegroundColor Green
}

# Função para obter informações da infraestrutura
function Get-InfrastructureInfo {
    Write-Host "📋 Obtendo informações da infraestrutura..." -ForegroundColor Cyan
    
    try {
        $outputs = aws cloudformation describe-stacks `
            --stack-name $StackName `
            --region $Region `
            --query "Stacks[0].Outputs" `
            --output json | ConvertFrom-Json
            
        $script:ecrUri = ($outputs | Where-Object { $_.OutputKey -eq "ECRRepositoryURI" }).OutputValue
        $script:clusterName = ($outputs | Where-Object { $_.OutputKey -eq "ECSClusterName" }).OutputValue
        $script:serviceName = ($outputs | Where-Object { $_.OutputKey -eq "ECSServiceName" }).OutputValue
        $script:loadBalancerDNS = ($outputs | Where-Object { $_.OutputKey -eq "LoadBalancerDNS" }).OutputValue
        
        Write-Host "✅ ECR URI: $script:ecrUri" -ForegroundColor Green
        Write-Host "✅ Cluster: $script:clusterName" -ForegroundColor Green
        Write-Host "✅ Service: $script:serviceName" -ForegroundColor Green
        Write-Host "✅ Load Balancer: $script:loadBalancerDNS" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Error "❌ Erro ao obter informações da infraestrutura. Stack criada?"
        return $false
    }
}

# Função para build e push da imagem para ECR
function Deploy-ImageToECR {
    Write-Host "🐳 Fazendo build e push da imagem para ECR..." -ForegroundColor Cyan
    
    # Login no ECR
    Write-Host "🔐 Fazendo login no ECR..." -ForegroundColor Yellow
    $loginCommand = aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $script:ecrUri.Split('/')[0]
    
    # Build da imagem
    Write-Host "🔨 Construindo imagem..." -ForegroundColor Yellow
    $fullImageTag = "$($script:ecrUri):$ImageTag"
    docker build -t $ProjectName .
    docker tag $ProjectName $fullImageTag
    
    # Push para ECR
    Write-Host "📤 Enviando imagem para ECR..." -ForegroundColor Yellow
    docker push $fullImageTag
    
    Write-Host "✅ Imagem enviada: $fullImageTag" -ForegroundColor Green
    return $fullImageTag
}

# Função para atualizar serviço ECS
function Update-ECSService {
    param([string]$ImageUri)
    
    Write-Host "🚀 Atualizando serviço ECS..." -ForegroundColor Cyan
    
    # Obter definição atual da task
    $taskDefArn = aws ecs describe-services `
        --cluster $script:clusterName `
        --services $script:serviceName `
        --region $Region `
        --query "services[0].taskDefinition" `
        --output text
        
    $taskDef = aws ecs describe-task-definition `
        --task-definition $taskDefArn `
        --region $Region `
        --query "taskDefinition" `
        --output json | ConvertFrom-Json
    
    # Atualizar imagem na definição
    $taskDef.containerDefinitions[0].image = $ImageUri
    
    # Remover campos não necessários para registro
    $cleanTaskDef = @{
        family = $taskDef.family
        networkMode = $taskDef.networkMode
        requiresCompatibilities = $taskDef.requiresCompatibilities
        cpu = $taskDef.cpu
        memory = $taskDef.memory
        executionRoleArn = $taskDef.executionRoleArn
        containerDefinitions = $taskDef.containerDefinitions
    }
    
    # Salvar nova definição
    $newTaskDefJson = $cleanTaskDef | ConvertTo-Json -Depth 10
    $tempFile = "temp-taskdef.json"
    $newTaskDefJson | Set-Content $tempFile
    
    # Registrar nova task definition
    Write-Host "📝 Registrando nova task definition..." -ForegroundColor Yellow
    $newTaskDefArn = aws ecs register-task-definition `
        --cli-input-json file://$tempFile `
        --region $Region `
        --query "taskDefinition.taskDefinitionArn" `
        --output text
    
    Remove-Item $tempFile
    
    # Atualizar serviço
    Write-Host "🔄 Atualizando serviço..." -ForegroundColor Yellow
    $updateParams = @(
        "--cluster", $script:clusterName,
        "--service", $script:serviceName,
        "--task-definition", $newTaskDefArn,
        "--region", $Region
    )
    
    if ($ForceNewDeployment) {
        $updateParams += "--force-new-deployment"
    }
    
    aws ecs update-service @updateParams | Out-Null
    
    # Aguardar deployment
    Write-Host "⏳ Aguardando deployment..." -ForegroundColor Yellow
    aws ecs wait services-stable `
        --cluster $script:clusterName `
        --services $script:serviceName `
        --region $Region
    
    Write-Host "✅ Serviço atualizado com sucesso!" -ForegroundColor Green
}

# Função para verificar saúde do deployment
function Test-DeploymentHealth {
    Write-Host "🏥 Verificando saúde do deployment..." -ForegroundColor Cyan
    
    # Status do serviço
    $serviceInfo = aws ecs describe-services `
        --cluster $script:clusterName `
        --services $script:serviceName `
        --region $Region `
        --query "services[0]" `
        --output json | ConvertFrom-Json
    
    $runningCount = $serviceInfo.runningCount
    $desiredCount = $serviceInfo.desiredCount
    
    Write-Host "📊 Containers: $runningCount/$desiredCount rodando" -ForegroundColor Yellow
    
    # Testar Load Balancer
    if ($script:loadBalancerDNS) {
        Write-Host "🌐 Testando Load Balancer..." -ForegroundColor Yellow
        
        $maxAttempts = 10
        $attempt = 0
        
        do {
            $attempt++
            try {
                $response = Invoke-WebRequest -Uri "http://$($script:loadBalancerDNS)" -TimeoutSec 10 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    Write-Host "✅ Aplicação respondendo!" -ForegroundColor Green
                    return $true
                }
            }
            catch {
                Write-Host "Tentativa $attempt/$maxAttempts - Aguardando resposta..." -ForegroundColor Yellow
                Start-Sleep 30
            }
        } while ($attempt -lt $maxAttempts)
        
        Write-Host "⚠️  Aplicação pode não estar respondendo ainda" -ForegroundColor Yellow
    }
    
    return $runningCount -eq $desiredCount
}

# Função para mostrar informações do deployment
function Show-DeploymentInfo {
    Write-Host "`n📊 Informações do Deployment:" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    Write-Host "🏷️  Ambiente: $Environment" -ForegroundColor Yellow
    Write-Host "🏷️  Imagem: $ImageTag" -ForegroundColor Yellow
    Write-Host "🌍 Região: $Region" -ForegroundColor Yellow
    Write-Host "🏗️  Cluster: $script:clusterName" -ForegroundColor Yellow
    Write-Host "⚙️  Serviço: $script:serviceName" -ForegroundColor Yellow
    
    if ($script:loadBalancerDNS) {
        Write-Host "🌐 URL: http://$($script:loadBalancerDNS)" -ForegroundColor Green
    }
}

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

try {
    # Verificar pré-requisitos
    if (-not (Test-AWSPrerequisites)) {
        exit 1
    }
    
    # Criar infraestrutura se solicitado
    Deploy-Infrastructure
    
    # Obter informações da infraestrutura
    if (-not (Get-InfrastructureInfo)) {
        Write-Host "⚠️  Execute com -CreateInfrastructure para criar a infraestrutura primeiro" -ForegroundColor Yellow
        exit 1
    }
    
    # Build e push da imagem
    $imageUri = Deploy-ImageToECR
    
    # Atualizar serviço ECS
    Update-ECSService -ImageUri $imageUri
    
    # Verificar saúde
    $healthy = Test-DeploymentHealth
    
    # Mostrar informações
    Show-DeploymentInfo
    
    if ($healthy) {
        Write-Host "`n🎉 Deploy AWS ECS Concluído com Sucesso!" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  Deploy concluído, mas verificação de saúde falhou" -ForegroundColor Yellow
    }
    
    Write-Host "📖 Para monitorar: aws ecs describe-services --cluster $script:clusterName --services $script:serviceName --region $Region" -ForegroundColor Yellow
    
} catch {
    Write-Error "❌ Erro durante o deploy AWS: $($_.Exception.Message)"
    exit 1
}
