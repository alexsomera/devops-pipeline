# =============================================================================
# Script de Deploy Local usando Docker
# Executa a aplicação localmente em containers
# =============================================================================

param(
    [string]$Environment = "development",
    [string]$ImageTag = "latest",
    [switch]$Clean = $false,
    [switch]$Build = $true,
    [switch]$Push = $false
)

# Configurações
$ErrorActionPreference = "Stop"
$ProjectName = "devops-pipeline"
$ContainerName = "$ProjectName-app"

Write-Host "🚀 Iniciando Deploy Local - $Environment" -ForegroundColor Green
Write-Host "=" * 50

# Função para verificar se o Docker está rodando
function Test-DockerRunning {
    try {
        docker version | Out-Null
        return $true
    }
    catch {
        Write-Error "❌ Docker não está rodando. Inicie o Docker Desktop primeiro."
        return $false
    }
}

# Função para limpar containers e imagens antigas
function Clear-OldResources {
    Write-Host "🧹 Limpando recursos antigos..." -ForegroundColor Yellow
    
    # Parar container se estiver rodando
    $existingContainer = docker ps -a -q --filter "name=$ContainerName"
    if ($existingContainer) {
        Write-Host "Parando container existente: $ContainerName"
        docker stop $ContainerName
        docker rm $ContainerName
    }
    
    # Remover imagem antiga se solicitado
    if ($Clean) {
        Write-Host "Removendo imagem antiga: $ProjectName"
        docker rmi $ProjectName -f 2>$null
    }
}

# Função para construir a imagem
function Build-DockerImage {
    Write-Host "🔨 Construindo imagem Docker..." -ForegroundColor Cyan
    
    # Ler variáveis do .env se existir
    if (Test-Path ".env") {
        Get-Content ".env" | ForEach-Object {
            if ($_ -match "^([^#][^=]+)=(.*)$") {
                [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
            }
        }
    }
    
    # Build da imagem
    $buildCommand = "docker build -t $ProjectName`:$ImageTag ."
    Write-Host "Executando: $buildCommand"
    
    Invoke-Expression $buildCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Imagem construída com sucesso!" -ForegroundColor Green
    } else {
        Write-Error "❌ Falha ao construir a imagem"
        exit 1
    }
}

# Função para fazer push da imagem (opcional)
function Push-DockerImage {
    if (-not $Push) { return }
    
    Write-Host "📤 Fazendo push da imagem para Docker Hub..." -ForegroundColor Cyan
    
    # Verificar se está logado no Docker Hub
    $loginStatus = docker info 2>&1 | Select-String "Username"
    if (-not $loginStatus) {
        Write-Host "⚠️  Faça login no Docker Hub primeiro: docker login"
        return
    }
    
    # Tag e push
    $dockerhubImage = "$env:DOCKERHUB_USERNAME/$ProjectName`:$ImageTag"
    docker tag "$ProjectName`:$ImageTag" $dockerhubImage
    docker push $dockerhubImage
    
    Write-Host "✅ Push concluído: $dockerhubImage" -ForegroundColor Green
}

# Função para executar o container
function Start-Container {
    Write-Host "🏃 Iniciando container..." -ForegroundColor Cyan
    
    $runCommand = @"
docker run -d \
  --name $ContainerName \
  -p 3000:80 \
  --restart unless-stopped \
  -e NODE_ENV=$Environment \
  $ProjectName`:$ImageTag
"@
    
    Write-Host "Executando: $runCommand"
    
    # Executar o comando (adaptado para PowerShell)
    $containerId = docker run -d --name $ContainerName -p 3000:80 --restart unless-stopped -e NODE_ENV=$Environment "$ProjectName`:$ImageTag"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container iniciado com sucesso!" -ForegroundColor Green
        Write-Host "🌐 Aplicação disponível em: http://localhost:3000" -ForegroundColor Yellow
        Write-Host "📋 Container ID: $containerId"
        
        # Mostrar logs iniciais
        Start-Sleep 2
        Write-Host "`n📄 Logs iniciais:" -ForegroundColor Cyan
        docker logs $ContainerName --tail 10
        
    } else {
        Write-Error "❌ Falha ao iniciar o container"
        exit 1
    }
}

# Função para verificar o status
function Show-Status {
    Write-Host "`n📊 Status do Deploy:" -ForegroundColor Cyan
    Write-Host "=" * 30
    
    # Status do container
    $containerStatus = docker ps --filter "name=$ContainerName" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    if ($containerStatus -match $ContainerName) {
        Write-Host "✅ Container: Rodando" -ForegroundColor Green
        Write-Host $containerStatus
    } else {
        Write-Host "❌ Container: Não encontrado" -ForegroundColor Red
    }
    
    # Verificar se a aplicação responde
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Aplicação: Respondendo (HTTP 200)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "⚠️  Aplicação: Não respondendo ainda" -ForegroundColor Yellow
    }
}

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

try {
    # Verificar pré-requisitos
    if (-not (Test-DockerRunning)) {
        exit 1
    }
    
    # Limpar recursos antigos
    Clear-OldResources
    
    # Construir imagem se solicitado
    if ($Build) {
        Build-DockerImage
    }
    
    # Push se solicitado
    Push-DockerImage
    
    # Iniciar container
    Start-Container
    
    # Mostrar status
    Show-Status
    
    Write-Host "`n🎉 Deploy Local Concluído com Sucesso!" -ForegroundColor Green
    Write-Host "📖 Para parar: docker stop $ContainerName" -ForegroundColor Yellow
    Write-Host "📖 Para ver logs: docker logs $ContainerName -f" -ForegroundColor Yellow
    
} catch {
    Write-Error "❌ Erro durante o deploy: $($_.Exception.Message)"
    exit 1
}
