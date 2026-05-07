FROM node:18-alpine AS builder

WORKDIR /app
COPY . .
# Optionnel : build si vous avez un projet Node
# RUN npm install && npm run build

FROM nginx:alpine

COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/
COPY *.html /usr/share/nginx/html/
COPY *.css /usr/share/nginx/html/
COPY *.js /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
