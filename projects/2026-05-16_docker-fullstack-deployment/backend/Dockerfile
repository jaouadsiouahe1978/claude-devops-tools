# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime (multi-stage pour réduire la taille)
FROM node:20-alpine
WORKDIR /app

# Copier les dépendances du stage précédent
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 5000
CMD ["node", "server.js"]
