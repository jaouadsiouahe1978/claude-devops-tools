FROM nginx:alpine

RUN apk add --no-cache openssl curl

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
