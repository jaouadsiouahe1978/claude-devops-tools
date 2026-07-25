#!/bin/bash
set -e

EMAIL="${EMAIL:-admin@example.com}"
DOMAINS="${DOMAINS:-example.com,www.example.com}"
RENEWAL_INTERVAL="${RENEWAL_INTERVAL:-86400}"
CERT_DIR="/etc/letsencrypt/live"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting Certbot automation service..."
log "Email: $EMAIL"
log "Domains: $DOMAINS"
log "Renewal interval: $RENEWAL_INTERVAL seconds"

# Convert comma-separated domains to array and prepare certbot arguments
IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"
CERTBOT_ARGS="-n --agree-tos --email $EMAIL --webroot -w /var/www/certbot"
for domain in "${DOMAIN_ARRAY[@]}"; do
  DOMAIN_CLEAN=$(echo "$domain" | xargs)
  CERTBOT_ARGS="$CERTBOT_ARGS -d $DOMAIN_CLEAN"
done

# Check if certificate already exists
PRIMARY_DOMAIN=$(echo "${DOMAIN_ARRAY[0]}" | xargs)
if [ ! -d "$CERT_DIR/$PRIMARY_DOMAIN" ]; then
  log "Certificate not found. Requesting new certificate from Let's Encrypt..."
  certbot certonly $CERTBOT_ARGS --pre-hook "/renewal-hook.sh pre" --post-hook "/renewal-hook.sh post" \
    || log "Certificate request may have failed, but continuing..."
else
  log "Certificate already exists at $CERT_DIR/$PRIMARY_DOMAIN"
fi

# Function to renew certificates
renew_certs() {
  log "Running certificate renewal check..."
  certbot renew --webroot -w /var/www/certbot --renew-hook "/renewal-hook.sh renew" \
    || log "Renewal check completed with warnings"
  log "Renewal check finished"
}

# Run initial renewal check
renew_certs

# Continuous renewal loop
log "Entering certificate renewal loop (interval: $RENEWAL_INTERVAL seconds)..."
while true; do
  sleep "$RENEWAL_INTERVAL"
  renew_certs
done
