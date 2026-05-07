# Multi-stage build pour optimiser la taille de l'image
FROM node:18-alpine AS builder

WORKDIR /app

# Copier le fichier package.json
COPY app/package.json .

# Installer les dépendances
RUN npm ci --only=production

# Stage final
FROM node:18-alpine

WORKDIR /app

# Installer dumb-init pour gérer les signaux correctement
RUN apk add --no-cache dumb-init

# Copier les dépendances depuis le builder
COPY --from=builder /app/node_modules ./node_modules

# Copier le code application
COPY app/index.js .
COPY app/package.json .

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

# Exposer le port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Utiliser dumb-init pour éviter les problèmes de signaux
ENTRYPOINT ["dumb-init", "--"]

# Commande de démarrage
CMD ["node", "index.js"]
