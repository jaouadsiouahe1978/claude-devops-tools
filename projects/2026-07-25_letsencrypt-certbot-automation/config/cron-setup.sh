#!/bin/bash
# Manual Cron Setup Script (for non-Docker deployment)
# Usage: sudo bash cron-setup.sh

set -e

EMAIL="${1:-admin@example.com}"
DOMAINS="${2:-example.com,www.example.com}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Setting up Certbot renewal cron job..."
log "Email: $EMAIL"
log "Domains: $DOMAINS"

if ! command -v certbot &> /dev/null; then
  log "ERROR: Certbot not installed"
  exit 1
fi

# Install renewal hook
if [ ! -f "$SCRIPT_DIR/certbot/renewal-hook.sh" ]; then
  log "ERROR: renewal-hook.sh not found"
  exit 1
fi

# Add renewal cron job (runs twice daily at 2 AM and 2 PM)
CRON_JOB="0 2,14 * * * certbot renew --quiet --post-hook \"$SCRIPT_DIR/certbot/renewal-hook.sh renew\""

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "certbot renew"; then
  log "Cron job already exists"
else
  log "Adding cron job..."
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  log "Cron job added successfully"
fi

# Add monitoring cron job (runs every hour)
MONITOR_CRON="0 * * * * $SCRIPT_DIR/monitoring/check-certs.sh"
if crontab -l 2>/dev/null | grep -q "check-certs.sh"; then
  log "Monitoring cron job already exists"
else
  log "Adding monitoring cron job..."
  (crontab -l 2>/dev/null; echo "$MONITOR_CRON") | crontab -
  log "Monitoring cron job added successfully"
fi

log "Cron setup completed"
log "View cron jobs with: crontab -l"
