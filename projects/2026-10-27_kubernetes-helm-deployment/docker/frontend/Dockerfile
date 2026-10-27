# Frontend - Nginx
FROM nginx:1.24-alpine

RUN apk add --no-cache curl

# Copier config nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/

# Copier le contenu web
COPY index.html /usr/share/nginx/html/

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
