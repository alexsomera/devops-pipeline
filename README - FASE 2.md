# Pipeline DevOps - Fase 1

Projeto desenvolvido para a Fase 1 da disciplina DevOps na Prática da PUCRS.  
O objetivo deste projeto é configurar um **pipeline de integração contínua (CI)** e criar **scripts de Infraestrutura como Código (IaC)** para provisionamento em nuvem.

---

## Pipeline de Integração Contínua

O pipeline é executado automaticamente nas seguintes situações:
- Push para a branch `main`.
- Abertura ou atualização de Pull Requests.

### Etapas do Pipeline
1. **Checkout do código**  
2. **Instalação de dependências** 
3. **Execução de testes automatizados**  
4. **Build da aplicação**
5. **Notificações** (status de execução no GitHub)

---

## Provisionamento de Infraestrutura

O arquivo [`iac/iac.yml`](iac/iac.yml) utiliza o AWS CloudFormation para criar recursos em nuvem.  

### Para criar a pilha na AWS
1. Acesse o console AWS.
2. Vá em **CloudFormation > Create Stack**.
3. Faça upload do arquivo [`iac/iac.yml`](iac/iac.ym)
4. Clique em **Next**, defina um nome para a stack e confirme.
5. Aguarde a criação.

---

## Como Executar Localmente

```bash
# Clonar o repositório
git clone https://github.com/alexsomera/devops-pipeline.git

# Acessar a pasta do projeto
cd pipeline-devops

# Instalar as dependencias
npm install

# Para rodar a aplicação
npm start

# A aplicação estará disponível em:
http://localhost:3000/

# Para executar os testes
npm test

# Para fazer o build da aplicação
npm run build
```
# 🐳 Guia de Containerização - Docker

Este documento explica como usar Docker para containerizar e executar a aplicação.

## 📋 Pré-requisitos

- Docker instalado ([Download Docker](https://www.docker.com/products/docker-desktop))
- Docker Compose (já incluído no Docker Desktop)

## 🚀 Como Executar com Docker

### Opção 1: Docker Build + Run (Manual)

```bash
# 1. Clonar o repositório
git clone https://github.com/alexsomera/devops-pipeline.git
cd devops-pipeline

# 2. Construir a imagem Docker
docker build -t devops-pipeline .

# 3. Executar o container
docker run -p 3000:80 devops-pipeline

# 4. Acessar a aplicação
# http://localhost:3000
```

### Opção 2: Docker Compose (Recomendado)

```bash
# 1. Clonar o repositório
git clone https://github.com/alexsomera/devops-pipeline.git
cd devops-pipeline

# 2. Configurar variáveis de ambiente
cp .env.example .env

# 3. Editar o arquivo .env com suas configurações
# DOCKERHUB_USERNAME=seu-usuario
# DOCKER_IMAGE_NAME=nome-da-sua-app
# IMAGE_TAG=latest

# 4. Executar com docker-compose
docker-compose up -d

# 5. Verificar se está rodando
docker-compose ps

# 6. Ver logs (opcional)
docker-compose logs -f

# 7. Parar os containers
docker-compose down
```

## 📁 Arquivos de Containerização

### Dockerfile
- **Multi-stage build** para otimizar o tamanho da imagem
- **Estágio 1**: Build da aplicação React com Node.js
- **Estágio 2**: Servir arquivos estáticos com Nginx
- **Resultado**: Imagem final ~20MB (Alpine Linux)

### docker-compose.yml
- Orquestração de containers
- Configuração de rede
- Health checks
- Restart automático
- Proxy reverso opcional

### nginx.conf
- Configuração do Nginx para servir SPA (Single Page Application)
- Suporte a roteamento do React Router
- Otimizações de performance

## 🔍 Comandos Úteis

```bash
# Listar imagens
docker images

# Listar containers rodando
docker ps

# Parar um container específico
docker stop <container-id>

# Remover uma imagem
docker rmi <image-name>

# Ver logs de um container
docker logs <container-name>

# Executar comando dentro do container
docker exec -it <container-name> sh

# Limpar recursos não utilizados
docker system prune
```

## 🏗️ Arquitetura da Aplicação

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Código React  │───▶│   Docker Build   │───▶│  Nginx + SPA    │
│   (src/)        │    │   (Multi-stage)  │    │  (Container)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   Imagem Docker  │
                       │   (~20MB)        │
                       └──────────────────┘
```

## ✅ Benefícios da Containerização

- **Portabilidade**: Roda em qualquer ambiente com Docker
- **Isolamento**: Não interfere com outras aplicações
- **Consistência**: Mesmo ambiente em dev, test e prod
- **Escalabilidade**: Fácil de replicar e escalar
- **Eficiência**: Imagem otimizada e leve

## 🔗 Links do Projeto

- **Repositório GitHub**: https://github.com/alexsomera/devops-pipeline
- **Pipeline CI/CD**: Configurado no GitHub Actions
- **Infraestrutura**: AWS CloudFormation (iac/iac.yml)
