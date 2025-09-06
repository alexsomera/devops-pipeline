# =============================================================================
# Script de Deploy para Produção usando Docker Compose
# Gerencia deploy com zero downtime e health checks
# =============================================================================

param(
    [ValidateSet("production", "staging", "development")]
    [string]$Environment = "production",
    
    [ValidateSet("rolling", "blue-green", "recreate")]
    [string]$Strategy = "rolling",
    
    [string]$ImageTag = "latest",
    [switch]$Backup = $false,
    [switch]$Rollback = $false,
    [string]$RollbackTag = ""
)

# Configurações
$ErrorActionPreference = "Stop"
$ProjectName = "devops-pipeline"
$ComposeFile = "docker-compose.yml"
$BackupDir = "backups"

Write-Host "🚀 Deploy para $Environment - Estratégia: $Strategy" -ForegroundColor Green
Write-Host "=" * 60

# Função para verificar pré-requisitos
function Test-Prerequisites {
    Write-Host "🔍 Verificando pré-requisitos..." -ForegroundColor Cyan
    
    # Docker
    try {
        docker version | Out-Null
        Write-Host "✅ Docker: OK" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Docker não disponível"
        return $false
    }
    
    # Docker Compose
    try {
        docker-compose version | Out-Null
        Write-Host "✅ Docker Compose: OK" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Docker Compose não disponível"
        return $false
    }
    
    # Arquivo de configuração
    if (-not (Test-Path $ComposeFile)) {
        Write-Error "❌ Arquivo $ComposeFile não encontrado"
        return $false
    }
    Write-Host "✅ Configuração: OK" -ForegroundColor Green
    
    # Arquivo .env
    if (-not (Test-Path ".env")) {
        Write-Host "⚠️  Arquivo .env não encontrado, usando .env.example" -ForegroundColor Yellow
        Copy-Item ".env.example" ".env"
    }
    Write-Host "✅ Variáveis de ambiente: OK" -ForegroundColor Green
    
    return $true
}

# Função para backup do estado atual
function Backup-CurrentState {
    if (-not $Backup) { return }
    
    Write-Host "💾 Criando backup do estado atual..." -ForegroundColor Cyan
    
    # Criar diretório de backup
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$BackupDir\backup-$timestamp"
    New-Item -ItemType Directory -Path $backupPath | Out-Null
    
    # Backup das configurações
    Copy-Item ".env" "$backupPath\.env" -ErrorAction SilentlyContinue
    Copy-Item $ComposeFile "$backupPath\$ComposeFile"
    
    # Backup dos volumes (se existirem)
    $volumes = docker volume ls -q --filter "name=$ProjectName"
    if ($volumes) {
        Write-Host "Fazendo backup dos volumes..." -ForegroundColor Yellow
        foreach ($volume in $volumes) {
            docker run --rm -v "${volume}:/data" -v "${PWD}/${backupPath}:/backup" busybox tar czf "/backup/$volume.tar.gz" -C /data .
        }
    }
    
    Write-Host "✅ Backup salvo em: $backupPath" -ForegroundColor Green
    return $backupPath
}

# Função para rollback
function Start-Rollback {
    if (-not $Rollback) { return }
    
    Write-Host "🔄 Iniciando rollback..." -ForegroundColor Yellow
    
    if (-not $RollbackTag) {
        Write-Error "❌ Tag de rollback não especificada. Use -RollbackTag"
        exit 1
    }
    
    # Atualizar variável de ambiente
    $envContent = Get-Content ".env"
    $envContent = $envContent -replace "IMAGE_TAG=.*", "IMAGE_TAG=$RollbackTag"
    $envContent | Set-Content ".env"
    
    Write-Host "🏃 Executando rollback para versão: $RollbackTag" -ForegroundColor Cyan
    docker-compose down
    docker-compose up -d
    
    Wait-ForHealthCheck
    Write-Host "✅ Rollback concluído!" -ForegroundColor Green
}

# Função para aguardar health check
function Wait-ForHealthCheck {
    Write-Host "🏥 Aguardando health check..." -ForegroundColor Cyan
    
    $maxAttempts = 30
    $attempt = 0
    
    do {
        $attempt++
        Start-Sleep 10
        
        # Verificar status dos containers
        $healthyContainers = docker-compose ps --services | ForEach-Object {
            $service = $_
            $status = docker-compose ps $service --format "{{.State}}"
            if ($status -eq "running") { $service }
        }
        
        $totalServices = (docker-compose ps --services).Count
        $healthyCount = $healthyContainers.Count
        
        Write-Host "Tentativa $attempt/$maxAttempts - Containers saudáveis: $healthyCount/$totalServices" -ForegroundColor Yellow
        
        if ($healthyCount -eq $totalServices) {
            # Testar endpoint da aplicação
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    Write-Host "✅ Health check passou!" -ForegroundColor Green
                    return $true
                }
            }
            catch {
                Write-Host "⚠️  Aplicação ainda não responde..." -ForegroundColor Yellow
            }
        }
        
    } while ($attempt -lt $maxAttempts)
    
    Write-Error "❌ Health check falhou após $maxAttempts tentativas"
    return $false
}

# Função para deploy rolling
function Deploy-Rolling {
    Write-Host "🔄 Executando deploy rolling..." -ForegroundColor Cyan
    
    # Atualizar imagem
    $envContent = Get-Content ".env"
    $envContent = $envContent -replace "IMAGE_TAG=.*", "IMAGE_TAG=$ImageTag"
    $envContent | Set-Content ".env"
    
    # Pull da nova imagem
    Write-Host "📥 Baixando nova imagem..." -ForegroundColor Yellow
    docker-compose pull
    
    # Deploy com recreação
    Write-Host "🚀 Atualizando serviços..." -ForegroundColor Yellow
    docker-compose up -d --no-deps --force-recreate
    
    # Aguardar health check
    if (-not (Wait-ForHealthCheck)) {
        Write-Error "❌ Deploy falhou no health check"
        exit 1
    }
    
    # Limpeza de imagens antigas
    Write-Host "🧹 Limpando imagens antigas..." -ForegroundColor Yellow
    docker image prune -f
    
    Write-Host "✅ Deploy rolling concluído!" -ForegroundColor Green
}

# Função para deploy blue-green
function Deploy-BlueGreen {
    Write-Host "🔵🟢 Executando deploy blue-green..." -ForegroundColor Cyan
    
    # Implementação simplificada do blue-green
    # Em produção real, você usaria Load Balancer externo
    
    Write-Host "⚠️  Deploy blue-green requer configuração de Load Balancer" -ForegroundColor Yellow
    Write-Host "Executando deploy rolling como alternativa..." -ForegroundColor Yellow
    
    Deploy-Rolling
}

# Função para mostrar status pós-deploy
function Show-PostDeployStatus {
    Write-Host "`n📊 Status Pós-Deploy:" -ForegroundColor Cyan
    Write-Host "=" * 40
    
    # Status dos containers
    Write-Host "🐳 Containers:" -ForegroundColor Yellow
    docker-compose ps
    
    # Uso de recursos
    Write-Host "`n💻 Uso de Recursos:" -ForegroundColor Yellow
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
    
    # Logs recentes
    Write-Host "`n📄 Logs Recentes:" -ForegroundColor Yellow
    docker-compose logs --tail=10
    
    # URLs de acesso
    Write-Host "`n🌐 URLs de Acesso:" -ForegroundColor Yellow
    Write-Host "• Aplicação: http://localhost:3000" -ForegroundColor Green
    
    if ($Environment -eq "production") {
        Write-Host "• Monitoramento: http://localhost:9090" -ForegroundColor Green
    }
}

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

try {
    # Rollback se solicitado
    if ($Rollback) {
        Start-Rollback
        exit 0
    }
    
    # Verificar pré-requisitos
    if (-not (Test-Prerequisites)) {
        exit 1
    }
    
    # Backup se solicitado
    $backupPath = Backup-CurrentState
    
    # Executar deploy baseado na estratégia
    switch ($Strategy) {
        "rolling" { Deploy-Rolling }
        "blue-green" { Deploy-BlueGreen }
        "recreate" {
            Write-Host "🔄 Executando deploy recreate..." -ForegroundColor Cyan
            docker-compose down
            docker-compose up -d
            Wait-ForHealthCheck
        }
    }
    
    # Status pós-deploy
    Show-PostDeployStatus
    
    Write-Host "`n🎉 Deploy $Environment Concluído com Sucesso!" -ForegroundColor Green
    Write-Host "📖 Para monitorar: docker-compose logs -f" -ForegroundColor Yellow
    Write-Host "📖 Para parar: docker-compose down" -ForegroundColor Yellow
    
    if ($backupPath) {
        Write-Host "📖 Backup disponível em: $backupPath" -ForegroundColor Yellow
    }
    
} catch {
    Write-Error "❌ Erro durante o deploy: $($_.Exception.Message)"
    
    # Em caso de erro, mostrar logs para debug
    Write-Host "`n🔍 Logs para debug:" -ForegroundColor Red
    docker-compose logs --tail=20
    
    exit 1
}
