# =========================================================================
# ESTÁGIO 1: Build - Compila a aplicação React
# =========================================================================
FROM node:18-alpine AS build

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos de manifesto de pacotes para o diretório de trabalho
COPY package*.json ./

# Instala todas as dependências (incluindo devDependencies necessárias para o build)
RUN npm ci

# Copia o restante do código da aplicação para o diretório de trabalho
COPY . .

# Faz o build da aplicação React (gera arquivos estáticos na pasta build/)
RUN npm run build

# =========================================================================
# ESTÁGIO 2: Produção - Serve os arquivos estáticos com nginx
# =========================================================================
FROM nginx:alpine

# Copia os arquivos buildados do estágio anterior para o diretório do nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copia o arquivo de health check para o diretório do nginx
COPY public/health.json /usr/share/nginx/html/health.json

# Copia a configuração personalizada do nginx para suportar SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expõe a porta 80 (padrão do nginx)
EXPOSE 80

# O nginx já tem um CMD padrão que inicia o servidor
CMD ["nginx", "-g", "daemon off;"]
