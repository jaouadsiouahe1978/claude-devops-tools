FROM node:18-alpine

WORKDIR /app

# Copier les dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le code source
COPY . .

# Port de l'application
EXPOSE 3000

# Health check intégré
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Démarrer l'application
CMD ["npm", "start"]
