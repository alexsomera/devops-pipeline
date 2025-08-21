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