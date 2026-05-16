# Utiliser Nginx comme serveur web léger
FROM nginx:alpine

# Copier la configuration Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copier les fichiers du site
COPY . /usr/share/nginx/html/

# Créer un utilisateur non-root
RUN addgroup -g 101 -S nginx && adduser -S nginx -u 101

# Changer les permissions
RUN chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
