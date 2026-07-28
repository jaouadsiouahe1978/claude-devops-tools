#!/bin/bash
set -e

CERT_DIR="/etc/letsencrypt/live"
ALERT_DAYS="${ALERT_DAYS:-30}"
ALERT_SCRIPT="/alert-expiry.sh"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting certificate expiry check (alert threshold: $ALERT_DAYS days)..."

if [ ! -d "$CERT_DIR" ]; then
  log "ERROR: Certificate directory not found at $CERT_DIR"
  exit 1
fi

CERTIFICATES_FOUND=0
CERTIFICATES_EXPIRING=0
REPORT=""

# Check each certificate
for cert_path in "$CERT_DIR"/*/cert.pem; do
  if [ -f "$cert_path" ]; then
    CERTIFICATES_FOUND=$((CERTIFICATES_FOUND + 1))

    CERT_DIR_NAME=$(dirname "$cert_path" | xargs basename)
    EXPIRY_DATE=$(openssl x509 -in "$cert_path" -noout -enddate | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    STATUS="OK"
    if [ "$DAYS_LEFT" -le 0 ]; then
      STATUS="EXPIRED"
      CERTIFICATES_EXPIRING=$((CERTIFICATES_EXPIRING + 1))
    elif [ "$DAYS_LEFT" -le "$ALERT_DAYS" ]; then
      STATUS="EXPIRING SOON"
      CERTIFICATES_EXPIRING=$((CERTIFICATES_EXPIRING + 1))
    fi

    log "Certificate: $CERT_DIR_NAME | Status: $STATUS | Expires: $EXPIRY_DATE | Days left: $DAYS_LEFT"
    REPORT="$REPORT\n- $CERT_DIR_NAME: $STATUS (expires $EXPIRY_DATE, $DAYS_LEFT days)"

    # Trigger alert if needed
    if [ "$DAYS_LEFT" -le "$ALERT_DAYS" ] && [ -f "$ALERT_SCRIPT" ]; then
      "$ALERT_SCRIPT" "$CERT_DIR_NAME" "$DAYS_LEFT" "$EXPIRY_DATE" "$STATUS" || log "Warning: Alert script failed"
    fi
  fi
done

log "Certificate check completed - Found: $CERTIFICATES_FOUND | Expiring/Expired: $CERTIFICATES_EXPIRING"
echo -e "$REPORT"

# Exit with warning code if certificates are expiring
[ "$CERTIFICATES_EXPIRING" -eq 0 ] || exit 0
