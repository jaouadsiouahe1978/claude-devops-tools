# ============================================================================
# STAGE 1: BUILDER (build stage - tout ce qui n'est pas nécessaire à runtime)
# ============================================================================
FROM node:20-alpine AS builder

LABEL stage=builder
LABEL description="Build stage with npm dependencies"

WORKDIR /app

# Copier les manifests
COPY app/package.json app/package-lock.json ./

# Installer TOUTES les dépendances (incluant devDependencies)
# On utilise npm ci pour une installation reproductible
RUN npm ci --prefer-offline --no-audit

# Copier le code source
COPY app/server.js ./

# Ici on pourrait faire du build TypeScript, minification, etc.
# Pour cet exemple, c'est simple : le JS est prêt

# ============================================================================
# STAGE 2: RUNTIME (image finale minimaliste)
# ============================================================================
FROM node:20-alpine

LABEL maintainer="DevOps Student <student@devops.local>"
LABEL version="1.0.0"
LABEL description="Optimized Node.js app with multi-stage build"

WORKDIR /app

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copier UNIQUEMENT les dépendances de production du stage builder
# node_modules contient seulement les packages de production (pas devDependencies)
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copier le code source
COPY --from=builder --chown=nodejs:nodejs /app/server.js ./

# Passer à l'utilisateur non-root
USER nodejs

# Exposer le port
EXPOSE 3000

# Variables d'environnement
ENV NODE_ENV=production \
    DOCKER_ENV=true \
    PORT=3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Lancer l'app
CMD ["node", "server.js"]
