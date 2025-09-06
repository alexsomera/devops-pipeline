# 📜 Scripts de Deploy usando Containers

Esta pasta contém scripts automatizados para deploy da aplicação usando Docker em diferentes ambientes e plataformas.

## 📁 Estrutura dos Scripts

| Script | Plataforma | Descrição |
|--------|------------|-----------|
| `deploy-local.ps1` | Windows | Deploy local para desenvolvimento |
| `deploy-production.ps1` | Windows | Deploy para produção com Docker Compose |
| `deploy-aws-ecs.ps1` | Windows | Deploy para AWS ECS |
| `container-utils.ps1` | Windows | Utilitários de gerenciamento |
| `deploy.sh` | Linux/Mac | Deploy simplificado para Unix |

## 🚀 Como Usar

### 1. Deploy Local (Desenvolvimento)

```powershell
# Deploy básico
.\scripts\deploy-local.ps1

# Deploy com limpeza
.\scripts\deploy-local.ps1 -Clean

# Build e push para Docker Hub
.\scripts\deploy-local.ps1 -Push -Environment production
```

**Recursos:**
- ✅ Build automático da imagem
- ✅ Limpeza de recursos antigos
- ✅ Health check da aplicação
- ✅ Push opcional para Docker Hub

### 2. Deploy Produção (Docker Compose)

```powershell
# Deploy para produção
.\scripts\deploy-production.ps1 -Environment production

# Deploy com backup
.\scripts\deploy-production.ps1 -Environment production -Backup

# Rollback para versão anterior
.\scripts\deploy-production.ps1 -Rollback -RollbackTag v1.0.0
```

**Estratégias de Deploy:**
- `rolling`: Atualização gradual (padrão)
- `blue-green`: Deploy sem downtime
- `recreate`: Recriação completa

### 3. Deploy AWS ECS

```powershell
# Criar infraestrutura e fazer deploy
.\scripts\deploy-aws-ecs.ps1 -CreateInfrastructure -Environment production

# Deploy apenas da aplicação
.\scripts\deploy-aws-ecs.ps1 -Environment production -ImageTag v1.2.0

# Forçar novo deployment
.\scripts\deploy-aws-ecs.ps1 -ForceNewDeployment
```

**Recursos:**
- ✅ Criação automática de infraestrutura AWS
- ✅ Build e push para ECR
- ✅ Atualização do serviço ECS
- ✅ Health check com Load Balancer

### 4. Utilitários de Container

```powershell
# Ver status geral
.\scripts\container-utils.ps1 -Action status

# Monitoramento em tempo real
.\scripts\container-utils.ps1 -Action monitor

# Ver logs
.\scripts\container-utils.ps1 -Action logs -LogLines 100

# Backup completo
.\scripts\container-utils.ps1 -Action backup

# Limpeza completa
.\scripts\container-utils.ps1 -Action cleanup

# Health check detalhado
.\scripts\container-utils.ps1 -Action health
```

### 5. Deploy Linux/Mac

```bash
# Dar permissão de execução
chmod +x scripts/deploy.sh

# Deploy básico
./scripts/deploy.sh

# Deploy com limpeza
./scripts/deploy.sh --clean

# Apenas mostrar status
./scripts/deploy.sh --status

# Ver logs em tempo real
./scripts/deploy.sh --logs
```

## ⚙️ Configuração

### Variáveis de Ambiente

Copie e configure o arquivo `.env`:

```bash
cp .env.example .env
```

Principais variáveis:

```bash
# Docker Hub (opcional)
DOCKERHUB_USERNAME=seu-usuario
DOCKER_IMAGE_NAME=devops-pipeline-app
IMAGE_TAG=latest

# Aplicação
APP_PORT=3000
CONTAINER_NAME=devops-pipeline-app
NODE_ENV=production

# Deploy
DEPLOYMENT_STRATEGY=rolling
REPLICAS=1
```

### Pré-requisitos

#### Para todos os scripts:
- Docker Desktop instalado e rodando
- PowerShell 5.1+ (Windows) ou Bash (Linux/Mac)

#### Para AWS ECS:
- AWS CLI configurado
- Credenciais AWS válidas
- Arquivo `iac/iac.yml` (CloudFormation template)

#### Para Docker Hub:
- Conta no Docker Hub
- Login: `docker login`

## 🔍 Troubleshooting

### Problemas Comuns

1. **Docker não está rodando**
   ```powershell
   # Verificar status
   docker version
   
   # Iniciar Docker Desktop
   ```

2. **Permissão negada (Linux/Mac)**
   ```bash
   chmod +x scripts/deploy.sh
   sudo usermod -aG docker $USER
   ```

3. **Build falha**
   ```powershell
   # Limpar cache do Docker
   docker builder prune -f
   
   # Verificar Dockerfile
   ```

4. **Container não responde**
   ```powershell
   # Ver logs
   .\scripts\container-utils.ps1 -Action logs
   
   # Health check
   .\scripts\container-utils.ps1 -Action health
   ```

### Logs e Debugging

```powershell
# Logs detalhados
docker-compose logs -f

# Status dos containers
docker ps -a

# Inspecionar container
docker inspect nome-do-container

# Entrar no container
docker exec -it nome-do-container sh
```

## 📊 Monitoramento

### Comandos Úteis

```powershell
# Status em tempo real
docker stats

# Logs de todos os serviços
docker-compose logs -f

# Health check manual
curl http://localhost:3000

# Verificar portas
netstat -an | findstr :3000
```

### Métricas Importantes

- **CPU Usage**: < 80%
- **Memory Usage**: < 512MB
- **Response Time**: < 2s
- **HTTP Status**: 200 OK

## 🔄 Estratégias de Deploy

### Rolling Update
- ✅ Zero downtime
- ✅ Fácil rollback
- ⚠️ Pode ter inconsistências temporárias

### Blue-Green
- ✅ Zero downtime garantido
- ✅ Rollback instantâneo
- ⚠️ Requer mais recursos

### Recreate
- ⚠️ Downtime durante deploy
- ✅ Simples de implementar
- ✅ Menor uso de recursos

## 📚 Referências

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [AWS ECS](https://docs.aws.amazon.com/ecs/)
- [PowerShell](https://docs.microsoft.com/powershell/)

## 🤝 Contribuindo

Para adicionar novos scripts ou melhorar os existentes:

1. Seguir o padrão de nomenclatura
2. Adicionar documentação inline
3. Incluir tratamento de erros
4. Testar em ambiente local primeiro
