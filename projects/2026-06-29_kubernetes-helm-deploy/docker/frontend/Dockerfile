# Frontend - Nginx static server
FROM nginx:latest-alpine

# Mettre à jour et installer minimal
RUN apk update && apk add --no-cache curl && rm -rf /var/cache/apk/*

# Copier config nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Créer fichier HTML de test
RUN mkdir -p /usr/share/nginx/html && \
    echo '<!DOCTYPE html>' > /usr/share/nginx/html/index.html && \
    echo '<html><head><title>MyApp Frontend</title>' >> /usr/share/nginx/html/index.html && \
    echo '<style>body{font-family:Arial;text-align:center;padding:50px}</style></head>' >> /usr/share/nginx/html/index.html && \
    echo '<body><h1>🚀 MyApp Frontend</h1>' >> /usr/share/nginx/html/index.html && \
    echo '<p>Running on Kubernetes with Helm</p>' >> /usr/share/nginx/html/index.html && \
    echo '<p>Connected to Backend: <span id="backend">Loading...</span></p>' >> /usr/share/nginx/html/index.html && \
    echo '<script>' >> /usr/share/nginx/html/index.html && \
    echo 'fetch("http://localhost:5000/api/status")' >> /usr/share/nginx/html/index.html && \
    echo '.then(r => r.json()).then(d => document.getElementById("backend").textContent = "✅ OK")' >> /usr/share/nginx/html/index.html && \
    echo '.catch(e => document.getElementById("backend").textContent = "❌ Error")' >> /usr/share/nginx/html/index.html && \
    echo '</script></body></html>' >> /usr/share/nginx/html/index.html

# Security: créer utilisateur nginx
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -c nginx -G nginx nginx && \
    chown -R nginx:nginx /usr/share/nginx/html

USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
