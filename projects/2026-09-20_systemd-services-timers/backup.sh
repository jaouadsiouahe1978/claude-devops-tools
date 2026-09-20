#!/bin/bash
# Backup script - example for systemd service
# This script is executed by the backup.service unit

set -e

BACKUP_DIR="/opt/backups"
LOG_FILE="${BACKUP_DIR}/backup.log"
SOURCE_DIR="/home"
RETENTION_DAYS=7

# Ensure log file exists
touch "$LOG_FILE"

# Log function
log_message() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
}

log_message "=== Backup Process Started ==="

# Perform backup
if [ -d "$SOURCE_DIR" ]; then
    BACKUP_FILE="${BACKUP_DIR}/data_$(date +%Y%m%d_%H%M%S).tar.gz"
    log_message "Creating backup: $BACKUP_FILE"

    # Create backup (ignore permission errors with || true)
    tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null || {
        log_message "WARNING: Some files could not be backed up"
    }

    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        log_message "Backup created successfully - Size: $SIZE"
    else
        log_message "ERROR: Backup file was not created"
        exit 1
    fi
else
    log_message "ERROR: Source directory $SOURCE_DIR not found"
    exit 1
fi

# Cleanup old backups (retention policy)
log_message "Cleaning up backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -name "data_*.tar.gz" -mtime +$RETENTION_DAYS -delete

BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/data_*.tar.gz 2>/dev/null | wc -l)
log_message "Current backups count: $BACKUP_COUNT"
log_message "=== Backup Process Completed ==="
