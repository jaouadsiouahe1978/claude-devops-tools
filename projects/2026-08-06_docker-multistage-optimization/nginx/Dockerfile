# ✅ Nginx lightweight reverse proxy

FROM nginx:alpine

# Créer un user non-root
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001

# Copier la config
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# User non-root
USER nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
