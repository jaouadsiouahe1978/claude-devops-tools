FROM node:18-alpine

WORKDIR /app

# Installer curl pour les health checks
RUN apk add --no-cache curl

COPY package*.json ./

RUN npm ci --only=production

COPY server.js .
COPY healthcheck.js .

EXPOSE 3000 9090

HEALTHCHECK --interval=15s --timeout=10s --retries=5 --start-period=20s \
    CMD node healthcheck.js

CMD ["node", "server.js"]
