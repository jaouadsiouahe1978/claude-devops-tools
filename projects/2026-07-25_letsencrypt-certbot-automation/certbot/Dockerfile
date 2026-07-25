FROM certbot/certbot:latest

RUN apk add --no-cache bash curl docker-cli jq

COPY init-certbot.sh /init-certbot.sh
COPY renewal-hook.sh /renewal-hook.sh

RUN chmod +x /init-certbot.sh /renewal-hook.sh

ENTRYPOINT ["/init-certbot.sh"]
