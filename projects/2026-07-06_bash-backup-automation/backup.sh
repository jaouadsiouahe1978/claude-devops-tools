#!/bin/bash
###############################################################################
# Automated Backup Script
# Performs incremental backups with compression and verification
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/backup-config.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

###############################################################################
# Logging Functions
###############################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
    log "INFO" "$@"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    log "SUCCESS" "$@"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    log "WARN" "$@"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
    log "ERROR" "$@"
}

###############################################################################
# Pre-flight Checks
###############################################################################

check_prerequisites() {
    log_info "Running pre-flight checks..."

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi

    # Check required commands
    local required_commands=("tar" "sha256sum" "df")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    # Check backup directory exists
    if [[ ! -d "${BACKUP_BASE_DIR}" ]]; then
        log_info "Creating backup directory: ${BACKUP_BASE_DIR}"
        mkdir -p "${BACKUP_BASE_DIR}"
        chmod 700 "${BACKUP_BASE_DIR}"
    fi

    # Check log directory exists
    if [[ ! -d "${BACKUP_LOG_DIR}" ]]; then
        log_info "Creating log directory: ${BACKUP_LOG_DIR}"
        mkdir -p "${BACKUP_LOG_DIR}"
        chmod 755 "${BACKUP_LOG_DIR}"
    fi

    log_success "Pre-flight checks passed"
}

###############################################################################
# Disk Space Checks
###############################################################################

check_disk_space() {
    log_info "Checking disk space..."

    local backup_mountpoint=$(df -P "${BACKUP_BASE_DIR}" | awk 'NR==2 {print $NF}')
    local disk_usage=$(df -P "${BACKUP_BASE_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
    local available_mb=$(df -BM "${BACKUP_BASE_DIR}" | awk 'NR==2 {print $4}' | sed 's/M//')

    log_info "Disk usage: ${disk_usage}% on ${backup_mountpoint}"
    log_info "Available space: ${available_mb}MB"

    if [[ $disk_usage -ge ${ERROR_DISK_PERCENT} ]]; then
        log_error "Disk usage is critical (${disk_usage}%)"
        return 1
    fi

    if [[ $disk_usage -ge ${WARN_DISK_PERCENT} ]]; then
        log_warn "Disk usage is high (${disk_usage}%)"
    fi

    return 0
}

###############################################################################
# Backup Creation
###############################################################################

create_backup() {
    log_info "Starting backup to: ${BACKUP_FILE}"

    local exclude_args=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_args+=" --exclude='${pattern}'"
    done

    local start_time=$(date +%s)

    # Create the backup
    if eval tar --ignore-failed-read -czf "${BACKUP_FILE}" \
        ${exclude_args} \
        "${BACKUP_DIRS[@]}" 2>&1 | tee -a "${LOG_FILE}"; then

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local size_mb=$(du -m "${BACKUP_FILE}" | cut -f1)

        log_success "Backup completed in ${duration}s"
        log_info "Backup size: ${size_mb}MB"

        # Check size warnings
        if [[ $size_mb -gt $ERROR_SIZE_MB ]]; then
            log_warn "Backup size exceeds error threshold (${size_mb}MB > ${ERROR_SIZE_MB}MB)"
        elif [[ $size_mb -gt $WARN_SIZE_MB ]]; then
            log_warn "Backup size is large (${size_mb}MB)"
        fi

        return 0
    else
        log_error "Backup failed"
        return 1
    fi
}

###############################################################################
# Integrity Verification
###############################################################################

verify_backup() {
    log_info "Verifying backup integrity..."

    if [[ ! -f "${BACKUP_FILE}" ]]; then
        log_error "Backup file not found: ${BACKUP_FILE}"
        return 1
    fi

    # Generate checksum
    log_info "Generating SHA256 checksum..."
    if sha256sum "${BACKUP_FILE}" > "${BACKUP_CHECKSUM}"; then
        log_success "Checksum generated: $(cut -d' ' -f1 ${BACKUP_CHECKSUM})"
    else
        log_error "Failed to generate checksum"
        return 1
    fi

    # Test archive integrity
    log_info "Testing archive integrity..."
    if tar -tzf "${BACKUP_FILE}" > /dev/null 2>&1; then
        log_success "Archive integrity verified"
        return 0
    else
        log_error "Archive is corrupted"
        return 1
    fi
}

###############################################################################
# Cleanup (called on exit)
###############################################################################

cleanup() {
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        log_success "Backup process completed successfully"
    else
        log_error "Backup process failed with code $exit_code"
        if [[ "${SEND_EMAIL}" == "true" ]]; then
            send_alert_email "FAILURE" "Backup failed with exit code $exit_code"
        fi
    fi

    exit $exit_code
}

###############################################################################
# Email Notifications
###############################################################################

send_alert_email() {
    local status="$1"
    local message="$2"

    if ! command -v mail &> /dev/null; then
        log_warn "mail command not found, skipping email notification"
        return 0
    fi

    local subject="[${status}] Backup on $(hostname) - $(date +%Y-%m-%d)"
    local body="Backup Status: ${status}
Host: $(hostname)
Date: $(date)
Backup File: ${BACKUP_FILE}
${message}

---
Log: ${LOG_FILE}"

    echo "${body}" | mail -s "${subject}" "${EMAIL_TO}"
    log_info "Email notification sent to ${EMAIL_TO}"
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "Starting backup script on $(date)"
    log_info "Backup configuration loaded from ${SCRIPT_DIR}/backup-config.sh"

    trap cleanup EXIT

    check_prerequisites
    check_disk_space || exit 1
    create_backup || exit 1
    verify_backup || exit 1

    if [[ "${SEND_EMAIL}" == "true" ]]; then
        local backup_size=$(du -h "${BACKUP_FILE}" | cut -f1)
        send_alert_email "SUCCESS" "Backup completed successfully. Size: ${backup_size}"
    fi
}

main "$@"
