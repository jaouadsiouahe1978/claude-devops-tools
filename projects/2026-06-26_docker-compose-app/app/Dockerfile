# Multi-stage build pour réduire la taille de l'image
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

# Stage final
FROM node:20-alpine

WORKDIR /app

# Copier les dépendances du builder
COPY --from=builder /app/node_modules ./node_modules

# Copier le code application
COPY index.js .
COPY package*.json ./

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/status', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["node", "index.js"]
