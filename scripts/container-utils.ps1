# =============================================================================
# Script de Utilitários para Gerenciamento de Containers
# Comandos úteis para manutenção e troubleshooting
# =============================================================================

param(
    [ValidateSet("status", "logs", "cleanup", "monitor", "backup", "restore", "health")]
    [string]$Action = "status",
    
    [string]$ContainerName = "devops-pipeline",
    [string]$BackupPath = "",
    [int]$LogLines = 50
)

# Configurações
$ErrorActionPreference = "Stop"
$ProjectName = "devops-pipeline"

Write-Host "🔧 Utilitários de Container - $Action" -ForegroundColor Green
Write-Host "=" * 40

# Função para mostrar status geral
function Show-Status {
    Write-Host "📊 Status dos Containers:" -ForegroundColor Cyan
    
    # Containers do projeto
    $containers = docker ps -a --filter "name=$ProjectName" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    if ($containers) {
        Write-Host $containers
    } else {
        Write-Host "❌ Nenhum container encontrado para o projeto $ProjectName" -ForegroundColor Red
    }
    
    Write-Host "`n🐳 Imagens do Projeto:" -ForegroundColor Cyan
    $images = docker images --filter "reference=$ProjectName*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    if ($images) {
        Write-Host $images
    } else {
        Write-Host "❌ Nenhuma imagem encontrada para o projeto $ProjectName" -ForegroundColor Red
    }
    
    Write-Host "`n💾 Volumes:" -ForegroundColor Cyan
    $volumes = docker volume ls --filter "name=$ProjectName" --format "table {{.Name}}\t{{.Driver}}"
    if ($volumes) {
        Write-Host $volumes
    } else {
        Write-Host "ℹ️  Nenhum volume específico do projeto" -ForegroundColor Gray
    }
    
    Write-Host "`n🌐 Redes:" -ForegroundColor Cyan
    $networks = docker network ls --filter "name=$ProjectName" --format "table {{.Name}}\t{{.Driver}}"
    if ($networks) {
        Write-Host $networks
    } else {
        Write-Host "ℹ️  Usando redes padrão" -ForegroundColor Gray
    }
}

# Função para mostrar logs
function Show-Logs {
    Write-Host "📄 Logs dos Containers:" -ForegroundColor Cyan
    
    # Verificar se há containers rodando
    $runningContainers = docker ps --filter "name=$ProjectName" --format "{{.Names}}"
    
    if ($runningContainers) {
        foreach ($container in $runningContainers) {
            Write-Host "`n--- Logs de $container ---" -ForegroundColor Yellow
            docker logs $container --tail $LogLines --timestamps
        }
    } else {
        Write-Host "❌ Nenhum container rodando para mostrar logs" -ForegroundColor Red
        
        # Mostrar logs do último container parado
        $lastContainer = docker ps -a --filter "name=$ProjectName" --format "{{.Names}}" | Select-Object -First 1
        if ($lastContainer) {
            Write-Host "`n📋 Logs do último container ($lastContainer):" -ForegroundColor Yellow
            docker logs $lastContainer --tail $LogLines --timestamps
        }
    }
}

# Função para limpeza
function Start-Cleanup {
    Write-Host "🧹 Iniciando limpeza..." -ForegroundColor Cyan
    
    $confirm = Read-Host "⚠️  Isso irá parar e remover containers, imagens e volumes. Continuar? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "❌ Operação cancelada" -ForegroundColor Yellow
        return
    }
    
    # Parar containers
    Write-Host "🛑 Parando containers..." -ForegroundColor Yellow
    $containers = docker ps --filter "name=$ProjectName" -q
    if ($containers) {
        docker stop $containers
    }
    
    # Remover containers
    Write-Host "🗑️  Removendo containers..." -ForegroundColor Yellow
    $allContainers = docker ps -a --filter "name=$ProjectName" -q
    if ($allContainers) {
        docker rm $allContainers
    }
    
    # Remover imagens
    Write-Host "🗑️  Removendo imagens..." -ForegroundColor Yellow
    $images = docker images --filter "reference=$ProjectName*" -q
    if ($images) {
        docker rmi $images -f
    }
    
    # Remover volumes órfãos
    Write-Host "🗑️  Removendo volumes órfãos..." -ForegroundColor Yellow
    docker volume prune -f
    
    # Remover redes não utilizadas
    Write-Host "🗑️  Removendo redes não utilizadas..." -ForegroundColor Yellow
    docker network prune -f
    
    # Limpeza geral do sistema
    Write-Host "🧹 Limpeza geral do Docker..." -ForegroundColor Yellow
    docker system prune -f
    
    Write-Host "✅ Limpeza concluída!" -ForegroundColor Green
}

# Função para monitoramento
function Start-Monitoring {
    Write-Host "📈 Iniciando monitoramento..." -ForegroundColor Cyan
    Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
    
    try {
        while ($true) {
            Clear-Host
            Write-Host "📊 Monitor de Containers - $(Get-Date)" -ForegroundColor Green
            Write-Host "=" * 60
            
            # Status dos containers
            Write-Host "`n🐳 Status:" -ForegroundColor Cyan
            docker ps --filter "name=$ProjectName" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            
            # Estatísticas de recursos
            Write-Host "`n💻 Recursos:" -ForegroundColor Cyan
            $stats = docker stats --no-stream --filter "name=$ProjectName" --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
            if ($stats) {
                Write-Host $stats
            } else {
                Write-Host "❌ Nenhum container rodando" -ForegroundColor Red
            }
            
            # Verificar saúde da aplicação
            Write-Host "`n🏥 Health Check:" -ForegroundColor Cyan
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 3 -UseBasicParsing
                Write-Host "✅ Aplicação respondendo (HTTP $($response.StatusCode))" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Aplicação não responde" -ForegroundColor Red
            }
            
            Start-Sleep 5
        }
    }
    catch {
        Write-Host "`n👋 Monitoramento encerrado" -ForegroundColor Yellow
    }
}

# Função para backup
function Start-Backup {
    Write-Host "💾 Criando backup..." -ForegroundColor Cyan
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "backups/container-backup-$timestamp"
    
    if (-not (Test-Path "backups")) {
        New-Item -ItemType Directory -Path "backups" | Out-Null
    }
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    
    # Backup de configurações
    Write-Host "📋 Backup de configurações..." -ForegroundColor Yellow
    Copy-Item "docker-compose.yml" "$backupDir/" -ErrorAction SilentlyContinue
    Copy-Item ".env" "$backupDir/" -ErrorAction SilentlyContinue
    Copy-Item "Dockerfile" "$backupDir/" -ErrorAction SilentlyContinue
    
    # Backup de volumes
    Write-Host "💾 Backup de volumes..." -ForegroundColor Yellow
    $volumes = docker volume ls --filter "name=$ProjectName" -q
    foreach ($volume in $volumes) {
        Write-Host "Fazendo backup do volume: $volume" -ForegroundColor Gray
        docker run --rm -v "${volume}:/data" -v "${PWD}/${backupDir}:/backup" busybox tar czf "/backup/$volume.tar.gz" -C /data .
    }
    
    # Backup de imagens
    Write-Host "🐳 Backup de imagens..." -ForegroundColor Yellow
    $images = docker images --filter "reference=$ProjectName*" --format "{{.Repository}}:{{.Tag}}"
    foreach ($image in $images) {
        $fileName = $image -replace "[:/]", "_"
        Write-Host "Salvando imagem: $image" -ForegroundColor Gray
        docker save $image | gzip > "$backupDir/$fileName.tar.gz"
    }
    
    Write-Host "✅ Backup criado em: $backupDir" -ForegroundColor Green
    
    # Listar conteúdo do backup
    Write-Host "`n📦 Conteúdo do backup:" -ForegroundColor Cyan
    Get-ChildItem $backupDir | Format-Table Name, Length, LastWriteTime
}

# Função para restaurar backup
function Start-Restore {
    if (-not $BackupPath) {
        Write-Host "❌ Caminho do backup não especificado. Use -BackupPath" -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path $BackupPath)) {
        Write-Error "❌ Backup não encontrado: $BackupPath"
        return
    }
    
    Write-Host "🔄 Restaurando backup de: $BackupPath" -ForegroundColor Cyan
    
    $confirm = Read-Host "⚠️  Isso irá sobrescrever configurações atuais. Continuar? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "❌ Operação cancelada" -ForegroundColor Yellow
        return
    }
    
    # Restaurar configurações
    Write-Host "📋 Restaurando configurações..." -ForegroundColor Yellow
    Copy-Item "$BackupPath/docker-compose.yml" "." -ErrorAction SilentlyContinue
    Copy-Item "$BackupPath/.env" "." -ErrorAction SilentlyContinue
    Copy-Item "$BackupPath/Dockerfile" "." -ErrorAction SilentlyContinue
    
    # Restaurar volumes
    Write-Host "💾 Restaurando volumes..." -ForegroundColor Yellow
    $volumeBackups = Get-ChildItem "$BackupPath/*.tar.gz" | Where-Object { $_.Name -notlike "*_*" }
    foreach ($volumeBackup in $volumeBackups) {
        $volumeName = $volumeBackup.BaseName
        Write-Host "Restaurando volume: $volumeName" -ForegroundColor Gray
        
        # Criar volume se não existir
        docker volume create $volumeName | Out-Null
        
        # Restaurar dados
        docker run --rm -v "${volumeName}:/data" -v "${BackupPath}:/backup" busybox tar xzf "/backup/$($volumeBackup.Name)" -C /data
    }
    
    # Restaurar imagens
    Write-Host "🐳 Restaurando imagens..." -ForegroundColor Yellow
    $imageBackups = Get-ChildItem "$BackupPath/*_*.tar.gz"
    foreach ($imageBackup in $imageBackups) {
        Write-Host "Carregando imagem: $($imageBackup.Name)" -ForegroundColor Gray
        gunzip -c "$($imageBackup.FullName)" | docker load
    }
    
    Write-Host "✅ Restore concluído!" -ForegroundColor Green
}

# Função para health check detalhado
function Test-Health {
    Write-Host "🏥 Verificação de Saúde Detalhada:" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    # Status do Docker
    Write-Host "`n🐳 Docker Engine:" -ForegroundColor Yellow
    try {
        docker version --format "{{.Server.Version}}" | Out-Null
        Write-Host "✅ Docker rodando" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Docker não está rodando" -ForegroundColor Red
    }
    
    # Containers
    Write-Host "`n📦 Containers:" -ForegroundColor Yellow
    $containers = docker ps --filter "name=$ProjectName" --format "{{.Names}}"
    if ($containers) {
        foreach ($container in $containers) {
            $health = docker inspect $container --format "{{.State.Health.Status}}"
            if ($health -eq "healthy" -or $health -eq "<no value>") {
                Write-Host "✅ $container : Saudável" -ForegroundColor Green
            } else {
                Write-Host "❌ $container : $health" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "❌ Nenhum container rodando" -ForegroundColor Red
    }
    
    # Conectividade
    Write-Host "`n🌐 Conectividade:" -ForegroundColor Yellow
    $ports = @(3000, 80, 443)
    foreach ($port in $ports) {
        try {
            $connection = Test-NetConnection -ComputerName "localhost" -Port $port -WarningAction SilentlyContinue
            if ($connection.TcpTestSucceeded) {
                Write-Host "✅ Porta $port : Aberta" -ForegroundColor Green
            } else {
                Write-Host "❌ Porta $port : Fechada" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ Porta $port : Erro na verificação" -ForegroundColor Red
        }
    }
    
    # Resposta HTTP
    Write-Host "`n🌍 Resposta HTTP:" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ HTTP Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "✅ Response Time: $($response.Headers['Date'])" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Não foi possível conectar à aplicação" -ForegroundColor Red
    }
    
    # Recursos do sistema
    Write-Host "`n💻 Recursos do Sistema:" -ForegroundColor Yellow
    $stats = docker stats --no-stream --filter "name=$ProjectName" --format "{{.Container}};{{.CPUPerc}};{{.MemUsage}}"
    if ($stats) {
        foreach ($stat in $stats) {
            $parts = $stat -split ";"
            $cpu = $parts[1] -replace "%", ""
            $mem = $parts[2] -split " / " | Select-Object -First 1
            
            if ([double]$cpu -lt 80) {
                Write-Host "✅ CPU ($($parts[0])): $($parts[1])" -ForegroundColor Green
            } else {
                Write-Host "⚠️  CPU ($($parts[0])): $($parts[1])" -ForegroundColor Yellow
            }
        }
    }
}

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

switch ($Action) {
    "status" { Show-Status }
    "logs" { Show-Logs }
    "cleanup" { Start-Cleanup }
    "monitor" { Start-Monitoring }
    "backup" { Start-Backup }
    "restore" { Start-Restore }
    "health" { Test-Health }
    default { 
        Write-Host "❌ Ação não reconhecida: $Action" -ForegroundColor Red
        Write-Host "Ações disponíveis: status, logs, cleanup, monitor, backup, restore, health" -ForegroundColor Yellow
    }
}
