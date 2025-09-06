#!/bin/bash

# Script de validação pós-deploy
# Valida se a aplicação foi deployada corretamente

set -e

echo "🔍 Iniciando validação pós-deploy..."

# Obtém o DNS do Load Balancer dos outputs do CloudFormation
ALB_DNS=$(aws cloudformation describe-stacks \
  --stack-name pipeline-devops-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
  --output text 2>/dev/null || echo "")

if [ -z "$ALB_DNS" ]; then
  echo "❌ Não foi possível obter o DNS do Load Balancer"
  exit 1
fi

echo "📡 Load Balancer DNS: $ALB_DNS"

# Testa conectividade básica
echo "🌐 Testando conectividade..."
if curl -f "http://$ALB_DNS" > /dev/null 2>&1; then
  echo "✅ Aplicação está respondendo"
else
  echo "❌ Aplicação não está respondendo"
  exit 1
fi

# Testa health check
echo "💓 Testando health check..."
if curl -f "http://$ALB_DNS/health.json" > /dev/null 2>&1; then
  echo "✅ Health check está funcionando"
else
  echo "❌ Health check não está funcionando"
  exit 1
fi

# Verifica se o ECS service está rodando
echo "🐳 Verificando status do ECS service..."
RUNNING_TASKS=$(aws ecs describe-services \
  --cluster pipeline-devops-cluster \
  --services pipeline-devops-service \
  --query 'services[0].runningCount' \
  --output text 2>/dev/null || echo "0")

if [ "$RUNNING_TASKS" -gt 0 ]; then
  echo "✅ $RUNNING_TASKS task(s) rodando no ECS"
else
  echo "❌ Nenhuma task rodando no ECS"
  exit 1
fi

echo "🎉 Validação pós-deploy concluída com sucesso!"
