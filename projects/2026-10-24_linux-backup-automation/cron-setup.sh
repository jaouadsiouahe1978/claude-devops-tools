#!/bin/bash
#
# Cron Setup - Automated scheduling of backup tasks
# Installs, configures, and manages backup cron jobs
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
ACTION="status"
CONFIG_FILE="backup-config.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL_BACKUP_TIME="02:00"      # 2 AM
INCREMENTAL_BACKUP_TIME="22:00" # 10 PM
VERIFY_BACKUP_TIME="03:00"    # 3 AM (weekly)
CLEANUP_TIME="04:00"          # 4 AM

log() {
  local level=$1
  shift
  local message="$*"

  case $level in
    INFO)
      echo -e "${GREEN}[✓]${NC} ${message}"
      ;;
    WARNING)
      echo -e "${YELLOW}[!]${NC} ${message}"
      ;;
    ERROR)
      echo -e "${RED}[✗]${NC} ${message}" >&2
      ;;
    DEBUG)
      echo -e "${BLUE}[•]${NC} ${message}"
      ;;
  esac
}

usage() {
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --install           Install backup cron jobs
  --remove            Remove all backup cron jobs
  --status            Show current cron jobs (default)
  --config FILE       Path to config file
  --full-time HH:MM   Time for full backup (default: 02:00)
  --incr-time HH:MM   Time for incremental backup (default: 22:00)
  --verify-time HH:MM Time for backup verification (default: 03:00)
  --dry-run           Show what would be done
  --help              Show this help message

SCHEDULE (default):
  Daily full backup:       2:00 AM (Sunday-Saturday)
  Daily incremental:      10:00 PM
  Weekly verification:     3:00 AM (Sunday)
  Maintenance:            4:00 AM (daily)

EXAMPLES:
  # Install with default schedule
  $0 --install --config backup-config.conf

  # Install with custom times
  $0 --install --config backup-config.conf \\
     --full-time 01:00 --verify-time 02:00

  # Remove all cron jobs
  $0 --remove

  # Check current schedule
  $0 --status

EOF
  exit 0
}

validate_time_format() {
  local time=$1

  if ! [[ $time =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
    log ERROR "Invalid time format: $time (use HH:MM)"
    return 1
  fi

  local hour=$(echo "$time" | cut -d: -f1)
  local minute=$(echo "$time" | cut -d: -f2)

  if [ "$hour" -gt 23 ] || [ "$minute" -gt 59 ]; then
    log ERROR "Invalid time values: $time"
    return 1
  fi

  return 0
}

time_to_cron() {
  local time=$1
  local minute=$(echo "$time" | cut -d: -f1)
  local hour=$(echo "$time" | cut -d: -f2)

  echo "$hour $minute"
}

validate_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    log ERROR "Config file not found: $CONFIG_FILE"
    exit 1
  fi

  log INFO "Config file: $CONFIG_FILE"
}

install_cron_jobs() {
  log INFO "Installing backup cron jobs..."

  # Validate time formats
  validate_time_format "$FULL_BACKUP_TIME" || return 1
  validate_time_format "$INCREMENTAL_BACKUP_TIME" || return 1
  validate_time_format "$VERIFY_BACKUP_TIME" || return 1

  # Get cron times
  local full_cron=$(time_to_cron "$FULL_BACKUP_TIME")
  local incr_cron=$(time_to_cron "$INCREMENTAL_BACKUP_TIME")
  local verify_cron=$(time_to_cron "$VERIFY_BACKUP_TIME")

  # Create a temporary crontab file
  local temp_cron=$(mktemp)

  # Get existing crontab (if any)
  crontab -l > "$temp_cron" 2>/dev/null || true

  # Remove old backup entries if they exist
  grep -v "backup-manager\|verify-backups\|backup.*cron" "$temp_cron" > "${temp_cron}.tmp" || true
  mv "${temp_cron}.tmp" "$temp_cron"

  # Add backup cron entries
  cat >> "$temp_cron" << EOF

# ===== BACKUP MANAGER JOBS =====

# Full backup daily at ${FULL_BACKUP_TIME}
${full_cron} * * ${SCRIPT_DIR}/backup-manager.sh --full --source-config ${SCRIPT_DIR}/${CONFIG_FILE} >> /var/log/backup-manager-cron.log 2>&1

# Incremental backup daily at ${INCREMENTAL_BACKUP_TIME}
${incr_cron} * * ${SCRIPT_DIR}/backup-manager.sh --incremental --source-config ${SCRIPT_DIR}/${CONFIG_FILE} >> /var/log/backup-manager-cron.log 2>&1

# Weekly backup verification (Sunday at ${VERIFY_BACKUP_TIME})
${verify_cron} * * 0 ${SCRIPT_DIR}/verify-backups.sh --backup-dir \$(grep '^BACKUP_DEST=' ${SCRIPT_DIR}/${CONFIG_FILE} | cut -d= -f2) >> /var/log/backup-manager-cron.log 2>&1

# Daily cleanup at ${CLEANUP_TIME}
0 4 * * * find \$(grep '^BACKUP_DEST=' ${SCRIPT_DIR}/${CONFIG_FILE} | cut -d= -f2) -maxdepth 1 -name "*-backup-*.tar*" -mtime +30 -delete >> /var/log/backup-manager-cron.log 2>&1

EOF

  # Install the new crontab
  if crontab "$temp_cron"; then
    log INFO "Cron jobs installed successfully"

    # Show what was installed
    log INFO "Installed cron schedule:"
    log INFO "  Full backup:      $FULL_BACKUP_TIME daily"
    log INFO "  Incremental:      $INCREMENTAL_BACKUP_TIME daily"
    log INFO "  Verification:     $VERIFY_BACKUP_TIME weekly (Sunday)"
    log INFO "  Cleanup:          04:00 daily"

    # Create log file
    if [ ! -f /var/log/backup-manager-cron.log ]; then
      if sudo -n touch /var/log/backup-manager-cron.log 2>/dev/null; then
        sudo chmod 640 /var/log/backup-manager-cron.log
        log INFO "Created cron log file: /var/log/backup-manager-cron.log"
      fi
    fi

    rm -f "$temp_cron"
    return 0
  else
    log ERROR "Failed to install cron jobs"
    rm -f "$temp_cron"
    return 1
  fi
}

remove_cron_jobs() {
  log INFO "Removing backup cron jobs..."

  local temp_cron=$(mktemp)

  # Get existing crontab
  if ! crontab -l > "$temp_cron" 2>/dev/null; then
    log WARNING "No existing crontab found"
    rm -f "$temp_cron"
    return 0
  fi

  # Remove backup entries
  grep -v "backup-manager\|verify-backups\|BACKUP MANAGER JOBS" "$temp_cron" > "${temp_cron}.tmp" || true
  mv "${temp_cron}.tmp" "$temp_cron"

  # Install the modified crontab
  if crontab "$temp_cron"; then
    log INFO "Cron jobs removed successfully"
    rm -f "$temp_cron"
    return 0
  else
    log ERROR "Failed to remove cron jobs"
    rm -f "$temp_cron"
    return 1
  fi
}

show_cron_status() {
  log INFO "Current backup cron jobs:"

  if crontab -l 2>/dev/null | grep -q "backup-manager\|verify-backups"; then
    echo ""
    crontab -l 2>/dev/null | grep -E "backup-manager|verify-backups|BACKUP MANAGER" || true
    echo ""
    log INFO "Cron jobs are installed"
    return 0
  else
    log WARNING "No backup cron jobs found"
    return 1
  fi
}

show_cron_logs() {
  log INFO "Recent cron job executions:"

  if [ -f /var/log/backup-manager-cron.log ]; then
    tail -20 /var/log/backup-manager-cron.log
  else
    log WARNING "Log file not found: /var/log/backup-manager-cron.log"
  fi
}

# === MAIN ===

main() {
  log INFO "Backup Cron Setup Tool started"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --install)
        ACTION="install"
        shift
        ;;
      --remove)
        ACTION="remove"
        shift
        ;;
      --status)
        ACTION="status"
        shift
        ;;
      --config)
        CONFIG_FILE="$2"
        shift 2
        ;;
      --full-time)
        FULL_BACKUP_TIME="$2"
        shift 2
        ;;
      --incr-time)
        INCREMENTAL_BACKUP_TIME="$2"
        shift 2
        ;;
      --verify-time)
        VERIFY_BACKUP_TIME="$2"
        shift 2
        ;;
      --dry-run)
        log INFO "DRY RUN MODE - no changes will be made"
        shift
        ;;
      --help)
        usage
        ;;
      *)
        log ERROR "Unknown option: $1"
        usage
        ;;
    esac
  done

  # Execute action
  case $ACTION in
    install)
      validate_config
      install_cron_jobs
      ;;
    remove)
      remove_cron_jobs
      ;;
    status)
      show_cron_status
      echo ""
      show_cron_logs
      ;;
    *)
      log ERROR "Unknown action: $ACTION"
      exit 1
      ;;
  esac
}

main "$@"
