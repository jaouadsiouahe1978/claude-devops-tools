#!/bin/bash
#
# Backup Manager - Automated Linux System Backup Tool
# Supports full and incremental backups with verification, rotation, and encryption
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BACKUP_TYPE="full"
SOURCE_CONFIG="backup-config.conf"
VERBOSE=false
DRY_RUN=false
ENCRYPT=false
PASSPHRASE=""

# === FUNCTIONS ===

log() {
  local level=$1
  shift
  local message="$*"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  case $level in
    DEBUG)
      [ "${VERBOSE}" = true ] && echo -e "${BLUE}[${timestamp}] DEBUG:${NC} ${message}"
      ;;
    INFO)
      echo -e "${GREEN}[${timestamp}] INFO:${NC} ${message}"
      ;;
    WARNING)
      echo -e "${YELLOW}[${timestamp}] WARNING:${NC} ${message}"
      ;;
    ERROR)
      echo -e "${RED}[${timestamp}] ERROR:${NC} ${message}" >&2
      ;;
  esac

  # Also write to log file if configured
  if [ -n "${LOG_FILE:-}" ]; then
    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}" 2>/dev/null || true
  fi
}

usage() {
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --full              Full backup (default)
  --incremental       Incremental backup (only changes)
  --source-config     Path to config file (default: backup-config.conf)
  --verbose           Verbose output
  --dry-run           Show what would be done without doing it
  --encrypt           Encrypt the backup
  --passphrase        Passphrase for encryption
  --help              Show this help message

EXAMPLES:
  # Full backup
  $0 --full --source-config backup-config.conf

  # Incremental backup with verbose output
  $0 --incremental --verbose

  # Encrypted backup
  $0 --full --encrypt --passphrase "secret123"

EOF
  exit 0
}

validate_config() {
  log INFO "Validating configuration..."

  if [ ! -f "$SOURCE_CONFIG" ]; then
    log ERROR "Configuration file not found: $SOURCE_CONFIG"
    exit 1
  fi

  # Source the configuration file
  # shellcheck source=/dev/null
  source "$SOURCE_CONFIG"

  # Validate required variables
  if [ -z "${SOURCE_DIRS:-}" ]; then
    log ERROR "SOURCE_DIRS not defined in config"
    exit 1
  fi

  if [ -z "${BACKUP_DEST:-}" ]; then
    log ERROR "BACKUP_DEST not defined in config"
    exit 1
  fi

  # Create backup destination if it doesn't exist
  if [ ! -d "$BACKUP_DEST" ]; then
    log INFO "Creating backup destination: $BACKUP_DEST"
    mkdir -p "$BACKUP_DEST" || {
      log ERROR "Failed to create backup destination"
      exit 1
    }
  fi

  log INFO "Configuration validated successfully"
}

check_disk_space() {
  log INFO "Checking available disk space..."

  local available=$(df "$BACKUP_DEST" | awk 'NR==2 {print $4}')
  local used=$(du -sk $SOURCE_DIRS 2>/dev/null | awk '{sum+=$1} END {print sum}')

  # Convert to human readable
  local available_gb=$((available / 1024 / 1024))
  local needed_gb=$((used / 1024))

  log INFO "Available space: ${available_gb}GB, Needed: ${needed_gb}GB"

  if [ "$available" -lt "$((used * 2))" ]; then
    log WARNING "Low disk space - backup may fail"
  fi
}

create_backup() {
  log INFO "Starting ${BACKUP_TYPE} backup..."

  local timestamp=$(date '+%Y-%m-%d-%H%M%S')
  local backup_file="${BACKUP_DEST}/${BACKUP_TYPE}-backup-${timestamp}"
  local compress_ext=""
  local compress_opt=""

  # Determine compression options
  case "${COMPRESSION:-gzip}" in
    gzip)
      compress_opt="-z"
      compress_ext=".tar.gz"
      ;;
    bzip2)
      compress_opt="-j"
      compress_ext=".tar.bz2"
      ;;
    xz)
      compress_opt="-J"
      compress_ext=".tar.xz"
      ;;
    none)
      compress_opt=""
      compress_ext=".tar"
      ;;
    *)
      log ERROR "Unknown compression type: ${COMPRESSION}"
      return 1
      ;;
  esac

  backup_file="${backup_file}${compress_ext}"

  # Build tar command
  local tar_cmd="tar ${compress_opt}"

  # Add exclusions
  if [ ${#EXCLUDE_PATTERNS[@]:-0} -gt 0 ]; then
    for pattern in "${EXCLUDE_PATTERNS[@]:-}"; do
      tar_cmd="$tar_cmd --exclude='$pattern'"
    done
  fi

  # Add verbose flag
  [ "${VERBOSE}" = true ] && tar_cmd="$tar_cmd -v"

  # Add incremental option
  if [ "$BACKUP_TYPE" = "incremental" ]; then
    local snar_file="${BACKUP_DEST}/${BACKUP_TYPE}.snar"
    tar_cmd="$tar_cmd -g '$snar_file'"
  fi

  # Add compression level
  if [ -n "${COMPRESSION_LEVEL:-}" ] && [ "$COMPRESSION" != "none" ]; then
    tar_cmd="$tar_cmd --${COMPRESSION:-gzip}-${COMPRESSION_LEVEL}"
  fi

  tar_cmd="$tar_cmd -cf '$backup_file' -C / $(echo $SOURCE_DIRS | tr ' ' '\n' | sed 's|^/||g' | tr '\n' ' ')"

  log DEBUG "Tar command: $tar_cmd"

  if [ "${DRY_RUN}" = true ]; then
    log INFO "DRY RUN: Would execute: $tar_cmd"
    return 0
  fi

  # Create the backup
  log INFO "Creating backup file: $backup_file"
  eval "$tar_cmd" || {
    log ERROR "Backup creation failed"
    return 1
  }

  # Get backup size
  local backup_size=$(du -h "$backup_file" | cut -f1)
  log INFO "Backup created successfully: $backup_size"

  # Generate checksums if enabled
  if [ "${GENERATE_CHECKSUMS:-true}" = true ]; then
    generate_checksums "$backup_file"
  fi

  # Encrypt if requested
  if [ "${ENCRYPT}" = true ]; then
    encrypt_backup "$backup_file"
  fi

  # Collect statistics if enabled
  if [ "${COLLECT_STATS:-true}" = true ]; then
    collect_stats "$backup_file" "$backup_size"
  fi

  # Cleanup old backups
  cleanup_old_backups

  # Send success alert
  if [ "${ALERT_ON_SUCCESS:-false}" = true ]; then
    send_alert "SUCCESS" "Backup completed: $backup_file ($backup_size)"
  fi

  log INFO "Backup process completed successfully"
  return 0
}

generate_checksums() {
  local backup_file=$1
  local checksum_file="${backup_file}.md5"

  log INFO "Generating checksums..."
  md5sum "$backup_file" > "$checksum_file" || {
    log WARNING "Failed to generate checksums"
    return 1
  }

  log DEBUG "Checksums saved to: $checksum_file"
}

encrypt_backup() {
  local backup_file=$1

  log INFO "Encrypting backup..."

  if [ -z "$PASSPHRASE" ]; then
    log ERROR "Passphrase required for encryption"
    return 1
  fi

  # Use openssl for encryption (AES-256-CBC)
  openssl enc -aes-256-cbc -in "$backup_file" -out "${backup_file}.enc" \
    -k "$PASSPHRASE" -P -md sha256 || {
    log ERROR "Encryption failed"
    return 1
  }

  # Remove original and rename encrypted file
  rm "$backup_file"
  mv "${backup_file}.enc" "$backup_file"

  log INFO "Backup encrypted successfully"
}

collect_stats() {
  local backup_file=$1
  local backup_size=$2
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local backup_name=$(basename "$backup_file")

  # Append to CSV if file doesn't exist, create header
  if [ ! -f "${STATS_FILE:-}" ]; then
    echo "timestamp,backup_name,size_bytes,size_human,type" > "${STATS_FILE}"
  fi

  local size_bytes=$(stat -f%z "$backup_file" 2>/dev/null || stat -c%s "$backup_file" 2>/dev/null || echo "0")
  echo "${timestamp},${backup_name},${size_bytes},${backup_size},${BACKUP_TYPE}" >> "${STATS_FILE}"

  log DEBUG "Statistics collected in: ${STATS_FILE}"
}

cleanup_old_backups() {
  log INFO "Cleaning up old backups..."

  if [ -z "${RETENTION_DAYS:-}" ]; then
    log DEBUG "Retention not configured, skipping cleanup"
    return 0
  fi

  local count=0
  while IFS= read -r backup_file; do
    if [ -f "$backup_file" ]; then
      rm -f "$backup_file"
      [ -f "${backup_file}.md5" ] && rm -f "${backup_file}.md5"
      log DEBUG "Removed old backup: $backup_file"
      ((count++))
    fi
  done < <(find "$BACKUP_DEST" -maxdepth 1 -name "*-backup-*.tar*" -type f -mtime "+${RETENTION_DAYS}")

  log INFO "Removed $count old backup(s)"
}

send_alert() {
  local status=$1
  local message=$2

  if [ -z "${ALERT_EMAIL:-}" ] || [ "${ENABLE_ALERTS:-false}" != true ]; then
    return 0
  fi

  if [ "$status" = "ERROR" ] && [ "${ALERT_ON_FAILURE:-true}" != true ]; then
    return 0
  fi

  if [ "$status" = "SUCCESS" ] && [ "${ALERT_ON_SUCCESS:-false}" != true ]; then
    return 0
  fi

  # Try using mail command if available
  if command -v mail &> /dev/null; then
    echo "$message" | mail -s "Backup Alert: $status" "$ALERT_EMAIL"
  else
    log WARNING "Mail command not available, skipping alert"
  fi
}

# === MAIN ===

main() {
  log INFO "Backup Manager started"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --full)
        BACKUP_TYPE="full"
        shift
        ;;
      --incremental)
        BACKUP_TYPE="incremental"
        shift
        ;;
      --source-config)
        SOURCE_CONFIG="$2"
        shift 2
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --encrypt)
        ENCRYPT=true
        shift
        ;;
      --passphrase)
        PASSPHRASE="$2"
        shift 2
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

  # Load and validate configuration
  validate_config

  # Check disk space
  check_disk_space

  # Create backup
  if create_backup; then
    log INFO "Backup completed successfully"
    exit 0
  else
    log ERROR "Backup failed"
    send_alert "ERROR" "Backup failed - check logs for details"
    exit 1
  fi
}

# Run main function
main "$@"
