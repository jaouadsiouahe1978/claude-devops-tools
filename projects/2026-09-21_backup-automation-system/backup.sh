#!/bin/bash
set -euo pipefail

# Main Backup Script
# Performs automated backups with retention management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"
LOG_FILE=""
BACKUP_START_TIME=""
BACKUP_END_TIME=""
BACKUP_SIZE=""

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Configuration file not found: $CONFIG_FILE" >&2
  exit 1
fi
source "$CONFIG_FILE"

# Initialize logging
setup_logging() {
  local log_date=$(date +%Y-%m-%d)
  LOG_FILE="${LOGS_DIR}/backup-${log_date}.log"

  if [[ ! -d "$LOGS_DIR" ]]; then
    mkdir -p "$LOGS_DIR"
  fi
}

# Log message with timestamp
log_message() {
  local message="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] ${message}" | tee -a "$LOG_FILE"
}

# Parse command line arguments
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      daily|weekly|monthly|full)
        BACKUP_TYPE="$1"
        ;;
      --dry-run)
        DRY_RUN=true
        ;;
      --no-compress)
        ENABLE_COMPRESSION=false
        ;;
      --verbose)
        VERBOSE=true
        ;;
      *)
        echo "Unknown argument: $1" >&2
        exit 1
        ;;
    esac
    shift
  done
}

# Check prerequisites
check_prerequisites() {
  log_message "Checking prerequisites..."

  local required_commands=("tar" "gzip" "date")
  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      log_message "ERROR: Required command not found: $cmd"
      exit 1
    fi
  done

  # Check if backup destination exists
  if [[ ! -d "$BACKUP_DEST" ]]; then
    log_message "Creating backup destination directory: $BACKUP_DEST"
    mkdir -p "$BACKUP_DEST"
  fi

  # Check disk space
  local available_space=$(df "$BACKUP_DEST" | awk 'NR==2 {print $4}')
  local available_gb=$((available_space / 1024 / 1024))
  log_message "Available disk space: ${available_gb} GB"

  if [[ $available_gb -lt 1 ]]; then
    log_message "WARNING: Less than 1 GB available for backups"
  fi
}

# Create backup filename based on type
generate_backup_filename() {
  local backup_date=$(date +%Y-%m-%d)
  local backup_time=$(date +%H-%M-%S)
  local extension="tar"

  if [[ "$ENABLE_COMPRESSION" == "true" ]]; then
    case "$COMPRESSION" in
      gzip)
        extension="tar.gz"
        ;;
      bzip2)
        extension="tar.bz2"
        ;;
      xz)
        extension="tar.xz"
        ;;
    esac
  fi

  echo "${BACKUP_PREFIX}-${BACKUP_TYPE}-${backup_date}-${backup_time}.${extension}"
}

# Build tar exclude options
build_exclude_options() {
  local exclude_opts=""
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    exclude_opts="${exclude_opts}--exclude='${pattern}' "
  done
  echo "$exclude_opts"
}

# Perform the actual backup
perform_backup() {
  local backup_filename=$(generate_backup_filename)
  local backup_filepath="${BACKUP_DEST}/${backup_filename}"
  local exclude_opts=$(build_exclude_options)

  log_message "Starting ${BACKUP_TYPE} backup: ${backup_filename}"
  BACKUP_START_TIME=$(date +%s)

  local tar_opts="-c"

  if [[ "$ENABLE_COMPRESSION" == "true" ]]; then
    case "$COMPRESSION" in
      gzip)
        tar_opts="${tar_opts}z"
        ;;
      bzip2)
        tar_opts="${tar_opts}j"
        ;;
      xz)
        tar_opts="${tar_opts}J"
        ;;
    esac
  fi

  if [[ "$VERBOSE" == "true" ]]; then
    tar_opts="${tar_opts}v"
  fi

  # Build tar command
  local tar_cmd="tar ${tar_opts}f '${backup_filepath}' ${exclude_opts}"
  for source in "${BACKUP_SOURCES[@]}"; do
    if [[ -e "$source" ]]; then
      tar_cmd="${tar_cmd} '${source}'"
    else
      log_message "WARNING: Source not found: $source"
    fi
  done

  # Execute backup
  if [[ "$DRY_RUN" == "true" ]]; then
    log_message "DRY-RUN: Would execute: ${tar_cmd}"
  else
    if eval "$tar_cmd" >> "$LOG_FILE" 2>&1; then
      BACKUP_END_TIME=$(date +%s)

      if [[ -f "$backup_filepath" ]]; then
        BACKUP_SIZE=$(du -h "$backup_filepath" | cut -f1)
        log_message "Backup completed successfully: ${backup_filename} (${BACKUP_SIZE})"

        # Verify backup integrity
        if [[ "$VERIFY_BACKUP" == "true" ]]; then
          verify_backup "$backup_filepath"
        fi

        # Create symlink to latest backup
        ln -sf "$backup_filepath" "${BACKUP_DEST}/latest.${extension:-tar}"
      else
        log_message "ERROR: Backup file was not created"
        return 1
      fi
    else
      log_message "ERROR: Backup command failed"
      return 1
    fi
  fi
}

# Verify backup integrity
verify_backup() {
  local backup_file="$1"
  log_message "Verifying backup integrity..."

  if tar -tzf "$backup_file" > /dev/null 2>&1; then
    log_message "Backup verification: PASSED"
  else
    log_message "ERROR: Backup verification failed"
    return 1
  fi
}

# Cleanup old backups based on retention policy
cleanup_old_backups() {
  log_message "Cleaning up old backups..."

  local current_date=$(date +%s)
  local file_count=0
  local files_deleted=0

  for backup_file in "${BACKUP_DEST}"/${BACKUP_PREFIX}-*.tar*; do
    if [[ -f "$backup_file" ]]; then
      ((file_count++))
      local file_date=$(stat -c %Y "$backup_file" 2>/dev/null || stat -f %m "$backup_file" 2>/dev/null)
      local file_age=$(( (current_date - file_date) / 86400 ))

      # Determine retention based on backup type
      local retention_days=$RETENTION_DAILY

      if [[ "$backup_file" == *"weekly"* ]]; then
        retention_days=$RETENTION_WEEKLY
      elif [[ "$backup_file" == *"monthly"* ]]; then
        retention_days=$RETENTION_MONTHLY
      fi

      if [[ $file_age -gt $retention_days ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
          log_message "DRY-RUN: Would delete: $(basename "$backup_file") (age: ${file_age} days)"
        else
          rm -f "$backup_file"
          ((files_deleted++))
          log_message "Deleted old backup: $(basename "$backup_file") (age: ${file_age} days)"
        fi
      fi
    fi
  done

  log_message "Cleanup complete: ${files_deleted}/${file_count} files deleted"
}

# Send email notification
send_notification() {
  if [[ "$ENABLE_EMAIL_NOTIFICATIONS" != "true" ]]; then
    return
  fi

  local status="$1"
  local subject="Backup ${status}: ${BACKUP_TYPE} ($(date +%Y-%m-%d))"

  if ! command -v mail &> /dev/null; then
    log_message "WARNING: mail command not found, skipping email notification"
    return
  fi

  local duration=$((BACKUP_END_TIME - BACKUP_START_TIME))
  local message="
Backup Status: ${status}
Type: ${BACKUP_TYPE}
Filename: $(basename "${BACKUP_DEST}"/${BACKUP_PREFIX}-*.tar* | tail -1)
Size: ${BACKUP_SIZE:-N/A}
Duration: ${duration} seconds
Timestamp: $(date)

Backup Destination: ${BACKUP_DEST}
Log File: ${LOG_FILE}
"

  if [[ "$status" == "SUCCESS" ]] && [[ "$EMAIL_ON_SUCCESS" != "true" ]]; then
    return
  fi

  if [[ "$status" == "FAILED" ]] && [[ "$EMAIL_ON_FAILURE" != "true" ]]; then
    return
  fi

  echo "$message" | mail -s "$subject" "$EMAIL_RECIPIENT"
}

# Main execution
main() {
  setup_logging
  parse_arguments "$@"

  log_message "=========================================="
  log_message "Backup process started"
  log_message "Type: ${BACKUP_TYPE}, Compression: ${ENABLE_COMPRESSION}"
  log_message "=========================================="

  check_prerequisites || exit 1

  if perform_backup; then
    cleanup_old_backups
    send_notification "SUCCESS"
    log_message "=========================================="
    log_message "Backup process completed successfully"
    log_message "=========================================="
    exit 0
  else
    send_notification "FAILED"
    log_message "=========================================="
    log_message "Backup process failed"
    log_message "=========================================="
    exit 1
  fi
}

main "$@"
