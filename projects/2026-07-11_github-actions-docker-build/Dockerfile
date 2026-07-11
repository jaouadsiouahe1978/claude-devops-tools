# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

COPY app/package*.json ./

RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine

WORKDIR /app

# Ajouter un utilisateur non-root
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Copier depuis le stage de build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Copier le code applicatif
COPY app/src ./src

# Labels pour métadonnées
LABEL maintainer="devops@example.com"
LABEL description="Node.js App - GitHub Actions CI/CD Demo"
LABEL version="1.0"

# Changer d'utilisateur
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

EXPOSE 3000

CMD ["node", "src/index.js"]
