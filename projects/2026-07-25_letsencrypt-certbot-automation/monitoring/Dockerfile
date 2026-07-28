FROM alpine:latest

RUN apk add --no-cache bash openssl curl jq

COPY check-certs.sh /check-certs.sh
COPY alert-expiry.sh /alert-expiry.sh

RUN chmod +x /check-certs.sh /alert-expiry.sh

CMD ["/bin/bash", "-c", "while true; do /check-certs.sh; sleep 3600; done"]
