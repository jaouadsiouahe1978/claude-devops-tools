FROM node:18-alpine

WORKDIR /app

# Copier app.js simple
COPY app.js .
COPY package*.json ./

# Installer les dépendances
RUN npm install

EXPOSE 3000

CMD ["node", "app.js"]
