#!/bin/bash
# Manual Certbot Renewal Script
# Usage: bash certbot-renewal.sh [email] [domains]

set -e

EMAIL="${1:-admin@example.com}"
DOMAINS="${2:-example.com,www.example.com}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting manual certificate renewal..."
log "Email: $EMAIL"
log "Domains: $DOMAINS"

if ! command -v certbot &> /dev/null; then
  log "ERROR: Certbot not installed"
  log "Install with: sudo apt-get install certbot python3-certbot-nginx"
  exit 1
fi

# Convert comma-separated domains to array
IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"
CERTBOT_ARGS="-n --agree-tos --email $EMAIL --webroot -w /var/www/certbot"

for domain in "${DOMAIN_ARRAY[@]}"; do
  DOMAIN_CLEAN=$(echo "$domain" | xargs)
  CERTBOT_ARGS="$CERTBOT_ARGS -d $DOMAIN_CLEAN"
done

# Request new certificate
log "Requesting certificate from Let's Encrypt..."
certbot certonly $CERTBOT_ARGS \
  --pre-hook "systemctl stop nginx || true" \
  --post-hook "systemctl start nginx || true" \
  || log "Certificate request may have failed"

# Verify certificate
PRIMARY_DOMAIN=$(echo "${DOMAIN_ARRAY[0]}" | xargs)
CERT_PATH="/etc/letsencrypt/live/$PRIMARY_DOMAIN/cert.pem"

if [ -f "$CERT_PATH" ]; then
  log "Certificate verified at $CERT_PATH"
  EXPIRY=$(openssl x509 -in "$CERT_PATH" -noout -enddate | cut -d= -f2)
  log "Certificate expires: $EXPIRY"
else
  log "ERROR: Certificate not found at $CERT_PATH"
  exit 1
fi

log "Certificate renewal completed successfully"
