# 🐳 Docker - NWERP Documentação

Este guia explica como executar a documentação do NWERP usando Docker e Docker Compose.

## 📋 Pré-requisitos

- Docker 24.0+ instalado
- Docker Compose 2.20+ (formato novo)

## 🚀 Início Rápido

### Desenvolvimento (com hot reload)

```bash
# Construir e iniciar
docker-compose up -d

# Visualizar logs
docker-compose logs -f

# Acessar
open http://localhost:3000
```

### Produção

```bash
# Construir e iniciar em modo produção
docker-compose -f docker-compose.prod.yml up -d

# Acessar
open http://localhost
```

## 📁 Estrutura de Arquivos

```
.
├── Dockerfile                 # Imagem de desenvolvimento
├── Dockerfile.prod           # Imagem de produção
├── docker-compose.yml        # Compose para desenvolvimento
├── docker-compose.prod.yml   # Compose para produção
├── nginx.conf               # Configuração do Nginx (produção)
├── .dockerignore            # Arquivos ignorados no build
└── README.Docker.md         # Este arquivo
```

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Iniciar serviços
docker-compose up -d

# Parar serviços
docker-compose down

# Reconstruir imagem
docker-compose build

# Reconstruir e reiniciar
docker-compose up -d --build

# Ver logs em tempo real
docker-compose logs -f docs

# Executar comando dentro do container
docker-compose exec docs sh

# Verificar saúde do container
docker-compose ps
```

### Produção

```bash
# Iniciar em produção
docker-compose -f docker-compose.prod.yml up -d

# Parar produção
docker-compose -f docker-compose.prod.yml down

# Reconstruir produção
docker-compose -f docker-compose.prod.yml build

# Ver logs produção
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔍 Troubleshooting

### Container não inicia

```bash
# Verificar logs
docker-compose logs docs

# Verificar status
docker-compose ps

# Remover volumes e reconstruir
docker-compose down -v
docker-compose up -d --build
```

### Hot reload não funciona

```bash
# Verificar se os volumes estão montados corretamente
docker-compose exec docs ls -la /app/nwerp

# Reiniciar o container
docker-compose restart docs
```

### Porta 3000 já em uso

```bash
# Alterar porta no docker-compose.yml
ports:
  - "3001:3000"  # Mude 3000 para 3001

# Ou parar o processo usando a porta
lsof -ti:3000 | xargs kill -9
```

## 🌐 Variáveis de Ambiente

### Desenvolvimento

```bash
# Criar arquivo .env
NODE_ENV=development
MINTLIFY_PORT=3000
```

### Produção

```bash
# Criar arquivo .env.prod
NODE_ENV=production
DOMAIN=docs.nwerp.com
```

## 🔐 HTTPS (Produção)

### Com Traefik (Recomendado)

O arquivo `docker-compose.prod.yml` já inclui labels para Traefik:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.docs.rule=Host(`docs.nwerp.com`)"
  - "traefik.http.routers.docs.entrypoints=websecure"
  - "traefik.http.routers.docs.tls.certresolver=letsencrypt"
```

### Com Certificado SSL Manual

Adicione ao `nginx.conf`:

```nginx
server {
    listen 443 ssl http2;
    server_name docs.nwerp.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # ... resto da configuração
}
```

E monte os certificados:

```yaml
volumes:
  - ./ssl:/etc/nginx/ssl:ro
```

## 📊 Monitoramento

### Health Check

```bash
# Verificar saúde do container
docker-compose ps

# Testar endpoint de saúde
curl http://localhost:3000/health
```

### Métricas

```bash
# Ver uso de recursos
docker stats nwerp-docs

# Ver logs formatados
docker-compose logs --tail=100 -f docs | jq
```

## 🚀 Deploy

### CI/CD com GitHub Actions

```yaml
name: Deploy Docs

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build and push
        run: |
          docker build -f Dockerfile.prod -t nwerp/docs:latest .
          docker push nwerp/docs:latest
      
      - name: Deploy to server
        run: |
          ssh user@server 'cd /app && docker-compose -f docker-compose.prod.yml pull && docker-compose -f docker-compose.prod.yml up -d'
```

### Deploy Manual

```bash
# Build da imagem
docker build -f Dockerfile.prod -t nwerp/docs:latest .

# Tag para registry
docker tag nwerp/docs:latest registry.nwerp.com/docs:latest

# Push para registry
docker push registry.nwerp.com/docs:latest

# Deploy no servidor
ssh user@server 'cd /app && docker-compose -f docker-compose.prod.yml pull && docker-compose -f docker-compose.prod.yml up -d'
```

## 🔄 Backup

### Backup dos arquivos de documentação

```bash
# Criar backup
docker run --rm -v nwerp-docs:/data -v $(pwd):/backup alpine tar czf /backup/docs-backup.tar.gz /data

# Restaurar backup
docker run --rm -v nwerp-docs:/data -v $(pwd):/backup alpine tar xzf /backup/docs-backup.tar.gz -C /
```

## 🎯 Otimizações

### Multi-stage Build

O `Dockerfile.prod` usa multi-stage build para reduzir o tamanho da imagem:

```dockerfile
FROM node:20-alpine AS builder
# ... build

FROM nginx:alpine
# ... apenas arquivos necessários
```

### Cache de Layers

```bash
# Build com cache
docker-compose build --pull

# Build sem cache
docker-compose build --no-cache
```

## 📝 Notas

- **Desenvolvimento**: Hot reload ativado para arquivos `.mdx` e `.json`
- **Produção**: Usa Nginx para servir arquivos estáticos com cache e compressão
- **Health Checks**: Configurados para Kubernetes/Docker Swarm
- **Logs**: Acessíveis via `docker-compose logs`

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs: `docker-compose logs -f`
2. Verifique a documentação oficial do Docker
3. Abra uma issue no repositório

---

**Versões:**
- Docker: 24.0+
- Docker Compose: 2.20+ (formato novo)
- Node.js: 20 Alpine
- Mintlify: Latest
- Nginx: Alpine

