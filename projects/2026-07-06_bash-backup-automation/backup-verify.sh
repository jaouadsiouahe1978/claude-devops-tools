#!/bin/bash
###############################################################################
# Backup Verification Script
# Checks integrity and generates reports
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
# Verify Single Backup
###############################################################################

verify_backup_file() {
    local backup_file="$1"
    local errors=0

    if [[ ! -f "$backup_file" ]]; then
        log_error "File not found: $backup_file"
        return 1
    fi

    log_info "Verifying: $(basename $backup_file)"

    # Check if checksum file exists
    if [[ ! -f "${backup_file}.sha256" ]]; then
        log_warn "Checksum file not found: ${backup_file}.sha256"
        ((errors++))
    else
        # Verify checksum
        log_info "  Checking SHA256..."
        if sha256sum -c "${backup_file}.sha256" --quiet; then
            log_success "  Checksum verified"
        else
            log_error "  Checksum FAILED"
            ((errors++))
        fi
    fi

    # Test archive integrity
    log_info "  Testing archive integrity..."
    if tar -tzf "$backup_file" > /dev/null 2>&1; then
        log_success "  Archive integrity OK"
    else
        log_error "  Archive is corrupted"
        ((errors++))
    fi

    # Get file statistics
    local size=$(du -h "$backup_file" | cut -f1)
    local files_count=$(tar -tzf "$backup_file" 2>/dev/null | wc -l)
    local mtime=$(date -r "$backup_file" '+%Y-%m-%d %H:%M:%S')

    log_info "  Size: ${size}, Files: ${files_count}, Date: ${mtime}"

    return $errors
}

###############################################################################
# Verify All Backups
###############################################################################

verify_all_backups() {
    log_info "Verifying all backups in ${BACKUP_BASE_DIR}..."
    echo ""

    local total_backups=0
    local verified_ok=0
    local verified_failed=0

    while IFS= read -r file; do
        ((total_backups++))

        if verify_backup_file "$file"; then
            ((verified_ok++))
        else
            ((verified_failed++))
            log_error "Backup verification failed: $(basename $file)"
        fi
        echo ""
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')

    # Summary
    echo "============================================"
    echo "Verification Summary"
    echo "============================================"
    echo "Total Backups: ${total_backups}"
    echo -e "Verified OK:   ${GREEN}${verified_ok}${NC}"
    echo -e "Verified FAIL: ${RED}${verified_failed}${NC}"
    echo "============================================"

    if [[ $verified_failed -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

###############################################################################
# Generate Health Report
###############################################################################

generate_health_report() {
    log_info "Generating health report..."

    local report_file="${BACKUP_LOG_DIR}/health-report-$(date +%Y-%m-%d).txt"

    {
        echo "=================================="
        echo "Backup Health Report"
        echo "Generated: $(date)"
        echo "=================================="
        echo ""

        echo "Backup Directory: ${BACKUP_BASE_DIR}"
        echo "Disk Usage:"
        df -h "${BACKUP_BASE_DIR}"
        echo ""

        echo "Backup List:"
        echo "-----------------------------------"
        while IFS= read -r file; do
            local basename=$(basename "$file")
            local size=$(du -h "$file" | cut -f1)
            local mtime=$(date -r "$file" '+%Y-%m-%d %H:%M:%S')
            local checksum_ok="?"

            if [[ -f "${file}.sha256" ]]; then
                if sha256sum -c "${file}.sha256" --quiet 2>/dev/null; then
                    checksum_ok="OK"
                else
                    checksum_ok="FAIL"
                fi
            fi

            printf "%-40s %10s %20s [%s]\n" "$basename" "$size" "$mtime" "$checksum_ok"
        done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')

        echo ""
        echo "Last 10 Backup Logs:"
        echo "-----------------------------------"
        tail -n 10 "${LOG_FILE}" 2>/dev/null || echo "Log file not found"

    } | tee "$report_file"

    log_success "Health report saved to: $report_file"
}

###############################################################################
# Simulate Restore
###############################################################################

test_restore() {
    local backup_file="$1"
    local test_dir="/tmp/restore-test-$(date +%s)"

    if [[ ! -f "$backup_file" ]]; then
        log_error "File not found: $backup_file"
        return 1
    fi

    log_info "Simulating restore from: $(basename $backup_file)"
    log_info "Test directory: ${test_dir}"

    mkdir -p "$test_dir"

    if tar -xzf "$backup_file" -C "$test_dir" 2>&1 | head -20; then
        log_success "Restore simulation successful"
        log_info "Files extracted: $(find "$test_dir" -type f | wc -l)"

        # Cleanup
        rm -rf "$test_dir"
        return 0
    else
        log_error "Restore simulation failed"
        rm -rf "$test_dir"
        return 1
    fi
}

###############################################################################
# Main Execution
###############################################################################

main() {
    local action="${1:-all}"

    case "$action" in
        all)
            verify_all_backups
            ;;
        latest)
            local latest=$(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}' | head -1)
            if [[ -n "$latest" ]]; then
                verify_backup_file "$latest"
            else
                log_error "No backups found"
                exit 1
            fi
            ;;
        health)
            generate_health_report
            ;;
        restore-test)
            local latest=$(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}' | head -1)
            if [[ -n "$latest" ]]; then
                test_restore "$latest"
            else
                log_error "No backups found"
                exit 1
            fi
            ;;
        *)
            if [[ -f "$action" ]]; then
                verify_backup_file "$action"
            else
                log_error "Unknown action: $action"
                echo "Usage: $0 {all|latest|health|restore-test|<file>}"
                exit 1
            fi
            ;;
    esac
}

main "$@"
