#!/bin/bash
# Health check script - monitoring backup service
# Can be executed by health-check.service or cron

BACKUP_DIR="/opt/backups"
LOG_FILE="${BACKUP_DIR}/health-check.log"
ALERT_EMAIL="admin@example.com"

log_check() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if backups exist
log_check "Starting health check..."

LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/data_*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    log_check "ERROR: No backup found in $BACKUP_DIR"
    echo "ERROR: No backup files found" >&2
    exit 1
fi

log_check "Latest backup: $(basename "$LATEST_BACKUP")"

# Check if backup is too old (more than 25 hours)
BACKUP_AGE=$(find "$LATEST_BACKUP" -mmin +1500 2>/dev/null)

if [ -n "$BACKUP_AGE" ]; then
    log_check "ERROR: Backup is older than 25 hours"
    echo "ERROR: Latest backup is too old" >&2
    exit 1
fi

# Check backup file size
BACKUP_SIZE=$(du -b "$LATEST_BACKUP" | cut -f1)
if [ "$BACKUP_SIZE" -lt 1000 ]; then
    log_check "WARNING: Backup size is suspiciously small: $BACKUP_SIZE bytes"
    echo "WARNING: Backup might be corrupted (size: $BACKUP_SIZE bytes)" >&2
    exit 2
fi

log_check "OK: Backup is valid - Size: $(du -h "$LATEST_BACKUP" | cut -f1)"
log_check "Health check completed successfully"
echo "OK: Backup health check passed"
exit 0
