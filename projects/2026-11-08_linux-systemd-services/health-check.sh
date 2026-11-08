#!/bin/bash

# Health check script for simple-service
# This script is run by systemd timer every minute

SERVICE_NAME="simple-service.service"
HEALTH_ENDPOINT="http://localhost:8888/health"
TIMEOUT=5
LOG_FILE="/var/log/simple-service/health-check.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if service is active
if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    log "ERROR: Service $SERVICE_NAME is not active"
    systemctl restart "$SERVICE_NAME"
    log "Attempted restart of $SERVICE_NAME"
    exit 1
fi

# Check HTTP health endpoint
response=$(curl -s -w "%{http_code}" -m "$TIMEOUT" "$HEALTH_ENDPOINT" 2>/dev/null)
http_code="${response: -3}"

if [[ $http_code == "200" ]]; then
    log "OK: Service is healthy (HTTP $http_code)"
    exit 0
else
    log "WARNING: Service returned HTTP $http_code"
    exit 1
fi
