#!/bin/bash
###############################################################################
# Backup Monitoring Script
# Monitors backup health and sends alerts
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/backup-config.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

###############################################################################
# Check Backup Exists
###############################################################################

check_backup_exists() {
    log_info "Checking if backup exists..."

    local latest=$(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | awk '{print $2}' | head -1)

    if [[ -z "$latest" ]]; then
        log_error "No backup found!"
        return 1
    fi

    local mtime=$(date -r "$latest" '+%s')
    local now=$(date '+%s')
    local age_hours=$(( (now - mtime) / 3600 ))
    local size=$(du -h "$latest" | cut -f1)

    log_success "Latest backup: $(basename $latest)"
    log_info "  Size: ${size}, Age: ${age_hours} hours"

    # Check if backup is too old (more than 25 hours)
    if [[ $age_hours -gt 25 ]]; then
        log_warn "Backup is old (${age_hours} hours)"
        return 1
    fi

    return 0
}

###############################################################################
# Check Backup Integrity
###############################################################################

check_backup_integrity() {
    log_info "Checking backup integrity..."

    local latest=$(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | awk '{print $2}' | head -1)

    if [[ -z "$latest" ]]; then
        log_error "No backup found"
        return 1
    fi

    if [[ ! -f "${latest}.sha256" ]]; then
        log_warn "Checksum file not found"
        return 1
    fi

    if ! sha256sum -c "${latest}.sha256" --quiet; then
        log_error "Checksum verification failed"
        return 1
    fi

    if ! tar -tzf "$latest" > /dev/null 2>&1; then
        log_error "Archive is corrupted"
        return 1
    fi

    log_success "Backup integrity verified"
    return 0
}

###############################################################################
# Check Disk Space
###############################################################################

check_disk_usage() {
    log_info "Checking disk usage..."

    local total_size=0
    local backup_count=$(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f | wc -l)

    while IFS= read -r size; do
        total_size=$((total_size + size))
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -exec du -m {} \; | awk '{print $1}')

    local disk_percent=$(df "${BACKUP_BASE_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')

    log_info "Total backup size: ${total_size}MB"
    log_info "Number of backups: ${backup_count}"
    log_info "Disk usage: ${disk_percent}%"

    if [[ $disk_percent -ge $ERROR_DISK_PERCENT ]]; then
        log_error "Disk usage is critical (${disk_percent}%)"
        return 1
    fi

    if [[ $disk_percent -ge $WARN_DISK_PERCENT ]]; then
        log_warn "Disk usage is high (${disk_percent}%)"
        return 1
    fi

    return 0
}

###############################################################################
# Send Alert
###############################################################################

send_alert() {
    local status="$1"
    local message="$2"

    if ! command -v mail &> /dev/null; then
        log_warn "mail command not found, skipping email"
        return
    fi

    local subject="[${status}] Backup Alert on $(hostname)"
    local body="Status: ${status}
Host: $(hostname)
Time: $(date)

${message}

---
Backup Directory: ${BACKUP_BASE_DIR}
Log File: ${LOG_FILE}"

    echo "${body}" | mail -s "${subject}" "${EMAIL_TO}"
    log_info "Alert email sent to ${EMAIL_TO}"
}

###############################################################################
# Generate Status Summary
###############################################################################

generate_status() {
    echo ""
    echo "============================================"
    echo "Backup Monitoring Status"
    echo "Generated: $(date)"
    echo "Host: $(hostname)"
    echo "============================================"
    echo ""

    echo "Backup Directory:"
    echo "  Location: ${BACKUP_BASE_DIR}"
    echo "  Disk Space:"
    df -h "${BACKUP_BASE_DIR}" | tail -1 | awk '{printf "    Total: %s, Used: %s, Available: %s (%%%s)\n", $2, $3, $4, $5}'
    echo ""

    echo "Latest Backups:"
    echo "-------------------------------------------"
    local count=0
    while IFS= read -r file; do
        if [[ $count -ge 5 ]]; then
            break
        fi
        local basename=$(basename "$file")
        local size=$(du -h "$file" | cut -f1)
        local mtime=$(date -r "$file" '+%Y-%m-%d %H:%M:%S')
        echo "  ${basename} (${size}) - ${mtime}"
        ((count++))
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')

    echo ""
    echo "Health Checks:"
    echo "-------------------------------------------"

    echo -n "  Backup Exists: "
    if check_backup_exists &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi

    echo -n "  Backup Integrity: "
    if check_backup_integrity &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi

    echo -n "  Disk Space: "
    if check_disk_usage &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi

    echo ""
    echo "============================================"
}

###############################################################################
# Main Monitoring Check
###############################################################################

main() {
    log_info "Starting backup monitoring"

    local has_error=0

    if ! check_backup_exists; then
        has_error=1
    fi

    if ! check_backup_integrity; then
        has_error=1
    fi

    if ! check_disk_usage; then
        has_error=1
    fi

    generate_status

    if [[ $has_error -eq 1 ]]; then
        log_error "Monitoring failed"
        if [[ "${SEND_EMAIL}" == "true" ]]; then
            send_alert "CRITICAL" "Backup monitoring detected issues. See logs for details."
        fi
        exit 1
    else
        log_success "All monitoring checks passed"
        exit 0
    fi
}

main "$@"
