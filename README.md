# Pipeline DevOps - Fase 2

## Sobre o Projeto

Projeto React containerizado com Docker e deploy na AWS usando práticas de DevOps, desenvolvido para a fase 2 da Disciplina DevOps na Prática do Curso de Análise e Desenvolvimento de Sistemas da PUCRS.

### Arquitetura AWS

```
Internet → ALB → ECS Fargate → React App (Nginx)
           ↓
        ECR (Docker Images)
```

## Pipeline de Integração Contínua

O pipeline é executado automaticamente nas seguintes situações:
- Push para a branch `main`.
## CI/CD Pipeline

O pipeline automatizado executa as seguintes etapas:

### **Continuous Integration**
- **Testes**: Jest + React Testing Library
- **Security**: Auditoria de dependências (`npm audit`)
- **Build**: Compilação da aplicação React
- **Artefatos**: Cache dos arquivos buildados

### **Continuous Deployment**
- **Docker**: Build da imagem multi-stage
- **ECR**: Push para repositório privado
- **Infrastructure**: Deploy via CloudFormation
- **ECS**: Atualização automática do serviço
- **Security Scan**: Verificação de vulnerabilidades
- **Health Check**: Validação da aplicação

## Infraestrutura como Código (IaC)

### **Template Principal: `iac/iac.yml`**

Template CloudFormation único que cria toda a infraestrutura necessária:

- **VPC** + Subnets + Internet Gateway  
- **Security Groups** (ALB + ECS)
- **ECR Repository** para imagens Docker
- **Application Load Balancer**
- **ECS Cluster + Service + Task Definition**
- **CloudWatch Logs** + Alarmes
- **Monitoramento** básico

### **Deploy da Infraestrutura:**

#### **AWS Academy:**
Obtenha as credenciais clicando em `Start Lab`
```bash
# Configura aws
aws configure

# Configura aws session token
aws configure set aws_session_token
```
#### **Deploy Manual:**
Rode o comando informe o e-mail que receberá as notificações e alarmes do CloudWatch
```bash
aws cloudformation deploy --template-file iac/iac.yml --stack-name pipeline-devops --capabilities CAPABILITY_IAM --parameter-overrides NotificationEmail=seuEmailAqui
```

## 🛠️ Tecnologias Utilizadas

### **DevOps & Infrastructure**
- **Docker** - Containerização multi-stage
- **AWS ECS Fargate** - Orquestração serverless
- **AWS ECR** - Repositório de imagens
- **AWS ALB** - Load balancer
- **CloudWatch** - Monitoramento e logs
- **CloudFormation** - Infrastructure as Code

### **CI/CD**
- **GitHub Actions** - Pipeline automatizado
- **Security Scanning** - Análise de vulnerabilidades
- **Automated Testing** - Execução automática de testes
- **Artifact Management** - Gerenciamento de artefatos

## 📁 Estrutura do Projeto

```
devops-pipeline/
├── 📁 src/                     # Código fonte React
├── 📁 public/                  # Arquivos públicos
├── 📁 iac/                     # Infrastructure as Code
│   └── iac.yml      # Template CloudFormation único
├── 📁 .github/workflows/       # GitHub Actions
│   └── pipeline-CI-CD.yml     # Pipeline principal
├── 🐳 Dockerfile              # Multi-stage Docker build
├── ⚙️ nginx.conf              # Configuração Nginx
└── 📋 package.json            # Dependências Node.js
```

## Monitoramento e Logs

### **CloudWatch Dashboards**
- **CPU e Memory**: Utilização do ECS
- **Load Balancer**: Requests e response time
- **Logs**: Logs estruturados da aplicação

### **Como acessar:**
1. Execute o deploy via GitHub Actions
2. No Summary do job, clique nos links de monitoramento
3. Ou acesse diretamente via console AWS


## Como Fazer Deploy

### **GitHub Actions (Automático)**
Toda alteração na branch `main` dispara o pipeline de CI/CD
```bash
# Push para main dispara deploy automático
git push origin main
```

### **Como acessar a aplicação após o deploy:**
1. Acesse [GitHub Actions](https://github.com/alexsomera/devops-pipeline/actions)
2. Clique na execução mais recente
3. Veja a aba **"Summary"** do job de deploy
4. O link da aplicação estará destacado no relatório

---

## React App com Vite

Este projeto foi migrado do Create React App para Vite para resolver vulnerabilidades de segurança e melhorar a performance.

### Como executar localmente

#### Clonar o repositório
```bash
git clone https://github.com/alexsomera/devops-pipeline.git
```
#### Acessar a pasta do projeto
```bash
cd devops-pipeline
```
#### Instalar as dependências
```bash
npm install
```

#### Executar o app em modo de desenvolvimento
```bash
npm run dev
```
Abra [http://localhost:3000](http://localhost:3000) para visualizar no navegador.

A página será recarregada automaticamente quando você fizer mudanças.

#### Build
Constrói o app para produção na pasta `build`.
Otimiza o build para melhor performance.
```bash
npm run build
```

#### Visualizar localmente o build de produção
```bash
npm run preview
```

#### `npm run lint`
Executa o ESLint para verificar problemas no código.
```bash
npm run lint
```

#### Executa os testes em modo interativo usando Vitest
```bash
npm test
```

#### Executa os testes em modo CI (sem watch)
```bash
npm run test:ci
```

## 🐳 Docker Local

### **Execução com Docker (Container Único)**
```bash
# Build da imagem local
docker build -t pipeline-devops-local:latest .

# Executar container
docker run -d \
  --name pipeline-devops-local \
  -p 3000:80 \
  --restart unless-stopped \
  pipeline-devops-local:latest

# Acessar aplicação
# http://localhost:3000
```

### **Comandos Úteis Docker**
```bash
# Ver logs do container
docker logs -f pipeline-devops-local

# Parar container
docker stop pipeline-devops-local

# Remover container
docker rm pipeline-devops-local

# Remover imagem
docker rmi pipeline-devops-local:latest

# Verificar status
docker ps | grep pipeline-devops-local
```

### **Docker Compose (Orquestração Multi-Container)**
```bash
# Subir todos os serviços
docker-compose up -d

# Ver logs de todos os serviços
docker-compose logs -f

# Parar todos os serviços
docker-compose down

# Rebuild e restart
docker-compose up -d --build
```

### **Environment Variables para Docker**
```bash
# Definir variáveis de ambiente
export DOCKERHUB_USERNAME=local
export DOCKER_IMAGE_NAME=pipeline-devops
export IMAGE_TAG=latest

# Ou usar arquivo .env
echo "DOCKERHUB_USERNAME=local" > .env
echo "DOCKER_IMAGE_NAME=pipeline-devops" >> .env
echo "IMAGE_TAG=latest" >> .env
```

### Tecnologias Utilizadas

- **React 18.3.1** - Biblioteca para construção de interfaces
- **Vite 7.1.4** - Build tool moderna e rápida
- **Vitest** - Framework de testes rápido
- **ESLint** - Linter para manter qualidade do código
- **Bootstrap 5.3.3** - Framework CSS

### Segurança

✅ **0 vulnerabilidades** - Todas as vulnerabilidades de segurança foram resolvidas com a migração para Vite.

Anteriormente o projeto tinha 29 vulnerabilidades com react-scripts, agora está completamente limpo.

## 📁 Estrutura do Projeto

```
devops-pipeline/
├── 📁 src/                     # Código fonte React
├── 📁 public/                  # Arquivos públicos
├── 📁 build/                  # Build de produção (gerado)
├── 📁 iac/                     # Infrastructure as Code
│   └── iac.yml                 # Template CloudFormation único
├── 📁 .github/workflows/       # GitHub Actions
│   └── pipeline-CI-CD.yml     # Pipeline principal CI/CD
├── 🐳 Dockerfile              # Multi-stage Docker build
├── 🐙 docker-compose.yml      # Orquestração multi-container
├── ⚙️ nginx.conf              # Configuração Nginx
├── 📋 package.json            # Dependências Node.js
├── ⚡ vite.config.js          # Configuração Vite
├── 🧪 vitest.config.js        # Configuração testes
└── 📚 README.md               # Documentação
```

### Migração Realizada
Esta aplicação foi migrada do Create React App para Vite pelos seguintes motivos:

1. **Segurança**: Eliminação de 29 vulnerabilidades
2. **Performance**: Build mais rápido com Vite
3. **Modernidade**: Ferramentas mais atualizadas
4. **Manutenibilidade**: Menos dependências problemáticas
