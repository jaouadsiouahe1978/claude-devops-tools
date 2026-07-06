#!/bin/bash
###############################################################################
# Backup Rotation Script
# Manages backup retention by removing old backups
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
# Backup Rotation by Count
###############################################################################

rotate_by_count() {
    log_info "Rotating backups: keeping last ${MAX_BACKUPS} backups"

    local backup_list=()
    local count=0

    # Get sorted list of backup files (newest first)
    while IFS= read -r file; do
        backup_list+=("$file")
        ((count++))
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')

    log_info "Found ${count} backups"

    # Remove old backups
    if [[ $count -gt $MAX_BACKUPS ]]; then
        log_warn "Removing $((count - MAX_BACKUPS)) old backups"

        for ((i = MAX_BACKUPS; i < count; i++)); do
            local file="${backup_list[$i]}"
            local size=$(du -h "$file" | cut -f1)

            log_info "Removing: $(basename $file) (${size})"

            # Remove backup and checksum
            rm -f "$file"
            rm -f "${file}.sha256"
        done

        log_success "Rotation completed"
    else
        log_info "No rotation needed"
    fi
}

###############################################################################
# Backup Rotation by Age
###############################################################################

rotate_by_age() {
    log_info "Rotating backups older than ${RETENTION_DAYS} days"

    local removed_count=0
    local deleted_size=0

    while IFS= read -r file; do
        local size=$(du -m "$file" | cut -f1)
        log_info "Removing: $(basename $file) (${size}MB)"

        rm -f "$file"
        rm -f "${file}.sha256"

        removed_count=$((removed_count + 1))
        deleted_size=$((deleted_size + size))
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -mtime +${RETENTION_DAYS})

    if [[ $removed_count -gt 0 ]]; then
        log_success "Removed ${removed_count} backups (${deleted_size}MB freed)"
    else
        log_info "No old backups to remove"
    fi
}

###############################################################################
# Generate Rotation Report
###############################################################################

generate_report() {
    log_info "Generating rotation report..."

    echo ""
    echo "============================================"
    echo "Backup Status Report"
    echo "============================================"
    echo "Generated: $(date)"
    echo "Location: ${BACKUP_BASE_DIR}"
    echo ""

    local total_size=0
    local backup_count=0

    echo "Current Backups:"
    echo "----------------------------------------"

    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local size=$(du -h "$file" | cut -f1)
            local mtime=$(date -r "$file" '+%Y-%m-%d %H:%M:%S')
            local basename=$(basename "$file")

            echo "  ${basename} (${size}, ${mtime})"

            total_size=$((total_size + $(du -m "$file" | cut -f1)))
            backup_count=$((backup_count + 1))
        fi
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')

    echo ""
    echo "Summary:"
    echo "----------------------------------------"
    echo "  Total Backups: ${backup_count}"
    echo "  Total Size: $(numfmt --to=iec-i --suffix=B ${total_size}M 2>/dev/null || echo "${total_size}MB")"
    echo "  Retention Policy: ${MAX_BACKUPS} backups or ${RETENTION_DAYS} days"
    echo ""
    echo "============================================"
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "Starting backup rotation"

    if [[ ! -d "${BACKUP_BASE_DIR}" ]]; then
        log_error "Backup directory not found: ${BACKUP_BASE_DIR}"
        exit 1
    fi

    # Apply both retention policies
    rotate_by_count
    rotate_by_age

    # Generate report
    generate_report
}

main "$@"
