#!/bin/bash

# Log Rotator
# Handles log file rotation and archival

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${1:-${SCRIPT_DIR}/config/monitoring.conf}"

source "$CONFIG_FILE"

# ============================================================
# FUNCTIONS
# ============================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@"
}

rotate_log() {
    local logfile=$1
    local archive_name="${logfile##*/}.$(date '+%Y%m%d')"
    local archive_path="${LOG_ARCHIVE_DIR}/${archive_name}"

    if [[ ! -f "$logfile" ]]; then
        log "WARN: Log file not found: $logfile"
        return
    fi

    local size=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile" 2>/dev/null)

    if [[ $size -gt 0 ]]; then
        log "Rotating: $logfile ($(numfmt --to=iec $size 2>/dev/null || echo "$size bytes"))"

        # Copy to archive
        cp "$logfile" "$archive_path" || {
            log "ERROR: Failed to copy $logfile"
            return 1
        }

        # Compress if enabled
        if [[ "$COMPRESS_LOGS" == "true" ]]; then
            gzip "$archive_path" && log "Compressed: ${archive_path}.gz" || log "WARN: Compression failed"
        fi

        # Clear original log file
        > "$logfile" && log "Cleared: $logfile" || log "ERROR: Failed to clear $logfile"
    fi
}

cleanup_old_logs() {
    local cutoff_days=$((RETENTION_DAYS * -1))

    log "Cleaning logs older than $RETENTION_DAYS days..."

    find "$LOG_ARCHIVE_DIR" -type f -mtime +"$RETENTION_DAYS" -delete
    log "Cleanup complete"
}

check_disk_usage() {
    local usage=$(du -sh "$LOG_ARCHIVE_DIR" 2>/dev/null | awk '{print $1}')
    log "Archive disk usage: $usage"
}

# ============================================================
# MAIN
# ============================================================

mkdir -p "$LOG_ARCHIVE_DIR"

case "${1:-}" in
    --rotate)
        for logfile in "${LOG_PATHS[@]}"; do
            rotate_log "$logfile"
        done
        ;;
    --cleanup)
        cleanup_old_logs
        check_disk_usage
        ;;
    --check)
        check_disk_usage
        ;;
    --full)
        log "Starting full rotation and cleanup..."
        for logfile in "${LOG_PATHS[@]}"; do
            rotate_log "$logfile"
        done
        cleanup_old_logs
        check_disk_usage
        ;;
    *)
        echo "Usage: $0 {--rotate|--cleanup|--check|--full}"
        exit 1
        ;;
esac

log "Operation complete"
