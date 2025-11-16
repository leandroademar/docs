# Use a imagem oficial do Node.js como base
FROM node:20-alpine

# Definir diretório de trabalho
WORKDIR /app

# Instalar o Mintlify CLI globalmente
RUN npm install -g mintlify@latest

# Copiar arquivos de documentação
COPY . .

# Expor porta padrão do Mintlify
EXPOSE 3000

# Comando para iniciar o servidor de desenvolvimento
CMD ["mintlify", "dev", "--host", "0.0.0.0", "--port", "3000"]

