FROM nginx:1.27-alpine

# Installer curl pour les health checks
RUN apk add --no-cache curl

# Créer le répertoire SSL
RUN mkdir -p /etc/nginx/ssl

# Exposer les ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f -k https://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
