# Pipeline DevOps - Fase 2

## 🌐 Aplicação em Produção

> **🔗 URL da aplicação disponível no GitHub Actions Summary após cada deploy**
> 
> _Acesse o workflow mais recente em [Actions](https://github.com/alexsomera/devops-pipeline/actions) para ver o link da aplicação_

## 📋 Sobre o Projeto

Projeto React containerizado com Docker e deploy na AWS usando práticas de DevOps, desenvolvido para a fase 2 da Disciplina DevOps na Prática do Curso de Análise e Desenvolvimento de Sistemas da PUCRS.

### 🏗️ Arquitetura AWS

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

### **Como acessar a aplicação após o deploy:**
1. Acesse [GitHub Actions](https://github.com/alexsomera/devops-pipeline/actions)
2. Clique na execução mais recente
3. Veja a aba **"Summary"** do job de deploy
4. O link da aplicação estará destacado no relatório

## 🏗️ Infraestrutura como Código (IaC)

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

#### **AWS Academy (PowerShell):**
```powershell
# Deploy rápido (nginx público)
.\scripts\academy-quick.ps1

# Deploy com aplicação customizada
.\scripts\academy-quick.ps1 -WithCustomImage
```

#### **Deploy Manual:**
```powershell
.\scripts\deploy.ps1 -ProjectName "meu-projeto" -Environment "academy" -UseCustomImage
```

## 🛠️ Tecnologias Utilizadas

### **Frontend**
- ⚛️ **React 18.3.1** - Interface de usuário
- 🎨 **Bootstrap 5.3.3** - Estilização
- 🧪 **Jest + RTL** - Testes automatizados
- 📱 **Responsive Design** - Compatível com mobile

### **DevOps & Infrastructure**
- 🐳 **Docker** - Containerização multi-stage
- ☁️ **AWS ECS Fargate** - Orquestração serverless
- 🔄 **AWS ECR** - Repositório de imagens
- ⚖️ **AWS ALB** - Load balancer
- 📊 **CloudWatch** - Monitoramento e logs
- 🏗️ **CloudFormation** - Infrastructure as Code

### **CI/CD**
- 🔄 **GitHub Actions** - Pipeline automatizado
- 🛡️ **Security Scanning** - Análise de vulnerabilidades
- 📈 **Automated Testing** - Execução automática de testes
- 📦 **Artifact Management** - Gerenciamento de artefatos

## 📁 Estrutura do Projeto

```
devops-pipeline/
├── 📁 src/                     # Código fonte React
├── 📁 public/                  # Arquivos públicos
├── 📁 iac/                     # Infrastructure as Code
│   └── iac.yml      # Template CloudFormation único
├── 📁 scripts/                 # Scripts de automação
│   ├── deploy.ps1             # Deploy principal
│   ├── destroy.ps1            # Destruir infraestrutura  
│   └── academy-quick.ps1      # Deploy rápido AWS Academy
├── 📁 .github/workflows/       # GitHub Actions
│   └── pipeline-CI-CD.yml     # Pipeline principal
├── 🐳 Dockerfile              # Multi-stage Docker build
├── ⚙️ nginx.conf              # Configuração Nginx
└── 📋 package.json            # Dependências Node.js
```

## 📊 Monitoramento e Logs

### **CloudWatch Dashboards**
- 📈 **CPU e Memory**: Utilização do ECS
- 🌐 **Load Balancer**: Requests e response time
- 📋 **Logs**: Logs estruturados da aplicação

### **Como acessar:**
1. Execute o deploy via GitHub Actions
2. No Summary do job, clique nos links de monitoramento
3. Ou acesse diretamente via console AWS



## Como Fazer Deploy

### **GitHub Actions (Automático)**
```bash
# Push para main dispara deploy automático
git push origin main
```

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

### 🔧 Tecnologias Utilizadas

- **React 18.3.1** - Biblioteca para construção de interfaces
- **Vite 7.1.4** - Build tool moderna e rápida
- **Vitest** - Framework de testes rápido
- **ESLint** - Linter para manter qualidade do código
- **Bootstrap 5.3.3** - Framework CSS

### 🛡️ Segurança

✅ **0 vulnerabilidades** - Todas as vulnerabilidades de segurança foram resolvidas com a migração para Vite.

Anteriormente o projeto tinha 29 vulnerabilidades com react-scripts, agora está completamente limpo.

### 📁 Estrutura do Projeto

```
src/
├── components/          # Componentes React
│   ├── About/
│   ├── CarForm/
│   ├── CarsList/
│   ├── Footer/
│   ├── Header/
│   ├── Home/
│   └── ...
├── App.jsx             # Componente principal
├── index.jsx           # Ponto de entrada
└── ...

public/                 # Arquivos estáticos
build/                  # Build de produção (gerado)
```

### 🔄 Migração Realizada

Esta aplicação foi migrada do Create React App para Vite pelos seguintes motivos:

1. **Segurança**: Eliminação de 29 vulnerabilidades
2. **Performance**: Build mais rápido com Vite
3. **Modernidade**: Ferramentas mais atualizadas
4. **Manutenibilidade**: Menos dependências problemáticas


## 🔄 Workflow do Desenvolvimento

1. **Desenvolvimento local**: `npm start`
2. **Executar testes**: `npm test`
3. **Commit e push**: O pipeline é executado automaticamente
4. **Verificar deploy**: Acessar [GitHub Actions](https://github.com/alexsomera/devops-pipeline/actions)
5. **Acessar aplicação**: Link disponível no Summary do workflow

---

> 🎉 **Deploy automático:** Toda alteração na branch `main` dispara o pipeline de CI/CD
> 
> 📱 **Link da aplicação:** Disponível no GitHub Actions Summary após cada deploy