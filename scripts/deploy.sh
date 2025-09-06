#!/bin/bash
# =============================================================================
# Script de Deploy Simplificado para Linux/Mac
# Deploy rápido usando Docker para desenvolvimento
# =============================================================================

set -e

# Configurações
PROJECT_NAME="devops-pipeline"
CONTAINER_NAME="$PROJECT_NAME-app"
IMAGE_TAG="latest"
PORT="3000"
DOCKER_PORT="80"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Função para verificar pré-requisitos
check_prerequisites() {
    log "🔍 Verificando pré-requisitos..."
    
    # Docker
    if ! command -v docker &> /dev/null; then
        error "Docker não está instalado"
    fi
    
    # Docker rodando
    if ! docker info &> /dev/null; then
        error "Docker não está rodando"
    fi
    
    # Dockerfile existe
    if [ ! -f "Dockerfile" ]; then
        error "Dockerfile não encontrado"
    fi
    
    log "✅ Pré-requisitos OK"
}

# Função para limpeza
cleanup() {
    log "🧹 Limpando recursos antigos..."
    
    # Parar container se estiver rodando
    if docker ps -q --filter "name=$CONTAINER_NAME" | grep -q .; then
        log "Parando container: $CONTAINER_NAME"
        docker stop $CONTAINER_NAME
    fi
    
    # Remover container se existir
    if docker ps -aq --filter "name=$CONTAINER_NAME" | grep -q .; then
        log "Removendo container: $CONTAINER_NAME"
        docker rm $CONTAINER_NAME
    fi
}

# Função para build
build_image() {
    log "🔨 Construindo imagem Docker..."
    
    docker build -t $PROJECT_NAME:$IMAGE_TAG .
    
    if [ $? -eq 0 ]; then
        log "✅ Imagem construída com sucesso"
    else
        error "Falha ao construir imagem"
    fi
}

# Função para executar container
run_container() {
    log "🚀 Iniciando container..."
    
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:$DOCKER_PORT \
        --restart unless-stopped \
        -e NODE_ENV=production \
        $PROJECT_NAME:$IMAGE_TAG
    
    if [ $? -eq 0 ]; then
        log "✅ Container iniciado com sucesso"
        log "🌐 Aplicação disponível em: http://localhost:$PORT"
    else
        error "Falha ao iniciar container"
    fi
}

# Função para aguardar aplicação
wait_for_app() {
    log "⏳ Aguardando aplicação ficar disponível..."
    
    max_attempts=30
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f http://localhost:$PORT &> /dev/null; then
            log "✅ Aplicação respondendo!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    warn "Aplicação pode não estar respondendo ainda"
}

# Função para mostrar status
show_status() {
    log "📊 Status do deploy:"
    echo ""
    
    # Status do container
    if docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q $CONTAINER_NAME; then
        echo -e "${GREEN}✅ Container: Rodando${NC}"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo -e "${RED}❌ Container: Não rodando${NC}"
    fi
    
    echo ""
    
    # Logs recentes
    log "📄 Logs recentes:"
    docker logs $CONTAINER_NAME --tail 10
}

# Função para mostrar ajuda
show_help() {
    echo "Script de Deploy - $PROJECT_NAME"
    echo ""
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  -h, --help      Mostrar esta ajuda"
    echo "  -c, --clean     Limpar recursos antes do deploy"
    echo "  -s, --status    Mostrar apenas o status"
    echo "  -l, --logs      Mostrar logs do container"
    echo "  --stop          Parar o container"
    echo "  --build-only    Apenas construir a imagem"
    echo ""
    echo "Exemplos:"
    echo "  $0                Deploy completo"
    echo "  $0 -c             Deploy com limpeza"
    echo "  $0 --status       Mostrar status"
    echo "  $0 --logs         Mostrar logs"
}

# Função para mostrar logs
show_logs() {
    if docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q $CONTAINER_NAME; then
        log "📄 Logs do container:"
        docker logs $CONTAINER_NAME -f
    else
        error "Container não está rodando"
    fi
}

# Função para parar container
stop_container() {
    if docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q $CONTAINER_NAME; then
        log "🛑 Parando container..."
        docker stop $CONTAINER_NAME
        log "✅ Container parado"
    else
        warn "Container não está rodando"
    fi
}

# =============================================================================
# MAIN
# =============================================================================

# Parâmetros padrão
CLEAN=false
STATUS_ONLY=false
LOGS_ONLY=false
STOP_ONLY=false
BUILD_ONLY=false

# Parse dos argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -s|--status)
            STATUS_ONLY=true
            shift
            ;;
        -l|--logs)
            LOGS_ONLY=true
            shift
            ;;
        --stop)
            STOP_ONLY=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        *)
            error "Opção desconhecida: $1"
            ;;
    esac
done

# Banner
echo -e "${BLUE}"
echo "=================================="
echo "   Deploy Script - $PROJECT_NAME"
echo "=================================="
echo -e "${NC}"

# Executar ações baseadas nos parâmetros
if [ "$STATUS_ONLY" = true ]; then
    show_status
    exit 0
fi

if [ "$LOGS_ONLY" = true ]; then
    show_logs
    exit 0
fi

if [ "$STOP_ONLY" = true ]; then
    stop_container
    exit 0
fi

# Deploy completo
check_prerequisites

if [ "$CLEAN" = true ]; then
    cleanup
fi

build_image

if [ "$BUILD_ONLY" = true ]; then
    log "🎉 Build concluído!"
    exit 0
fi

cleanup
run_container
wait_for_app
show_status

log "🎉 Deploy concluído com sucesso!"
log "📖 Para ver logs: $0 --logs"
log "📖 Para parar: $0 --stop"
