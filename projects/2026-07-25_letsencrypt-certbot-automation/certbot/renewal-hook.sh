#!/bin/bash
set -e

HOOK_TYPE="${1:-post}"
NGINX_CONTAINER="nginx-ssl"
ALERT_SCRIPT="/monitoring/alert-expiry.sh"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [HOOK:$HOOK_TYPE] $*"
}

log "Executing $HOOK_TYPE hook..."

case "$HOOK_TYPE" in
  pre)
    log "Pre-hook: Preparing for certificate validation..."
    ;;
  post)
    log "Post-hook: Certificate obtained successfully, reloading Nginx..."
    if docker ps | grep -q "$NGINX_CONTAINER"; then
      docker exec "$NGINX_CONTAINER" nginx -s reload || {
        log "WARNING: Failed to reload Nginx, retrying..."
        sleep 5
        docker exec "$NGINX_CONTAINER" nginx -s reload
      }
      log "Nginx reloaded successfully"
    else
      log "WARNING: Nginx container not running"
    fi
    ;;
  renew)
    log "Renewal hook: Certificate renewed, reloading Nginx..."
    if docker ps | grep -q "$NGINX_CONTAINER"; then
      docker exec "$NGINX_CONTAINER" nginx -s reload || log "WARNING: Failed to reload Nginx"
      log "Nginx reloaded successfully"
    fi
    # Run monitoring check after successful renewal
    if [ -f "$ALERT_SCRIPT" ]; then
      log "Running certificate monitoring check..."
      bash "$ALERT_SCRIPT" || log "Monitoring check completed with warnings"
    fi
    ;;
  *)
    log "ERROR: Unknown hook type: $HOOK_TYPE"
    exit 1
    ;;
esac

log "Hook execution completed"
