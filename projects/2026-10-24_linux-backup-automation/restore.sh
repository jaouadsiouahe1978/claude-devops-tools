#!/bin/bash
#
# Restore Script - Selective file restoration from backups
# Supports listing contents and restoring individual files or entire backups
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
BACKUP_FILE=""
ACTION="list"
FILE_TO_RESTORE=""
RESTORE_DEST="/tmp/restored"
FORCE=false

log() {
  local level=$1
  shift
  local message="$*"

  case $level in
    INFO)
      echo -e "${GREEN}[INFO]${NC} ${message}"
      ;;
    WARNING)
      echo -e "${YELLOW}[WARNING]${NC} ${message}"
      ;;
    ERROR)
      echo -e "${RED}[ERROR]${NC} ${message}" >&2
      ;;
    DEBUG)
      echo -e "${BLUE}[DEBUG]${NC} ${message}"
      ;;
  esac
}

usage() {
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --backup FILE       Path to backup archive
  --list              List contents of backup (default)
  --restore           Restore specific file(s)
  --file FILE         File to restore (path inside backup)
  --dest DIRECTORY    Destination directory for restore
  --all               Restore entire backup
  --force             Overwrite existing files
  --help              Show this help message

EXAMPLES:
  # List contents of backup
  $0 --backup /mnt/backups/full-backup-*.tar.gz --list

  # Restore a specific file
  $0 --backup /mnt/backups/full-backup-*.tar.gz \\
     --restore --file /etc/passwd --dest /tmp/restore/

  # Restore entire backup
  $0 --backup /mnt/backups/full-backup-*.tar.gz \\
     --restore --all --dest /tmp/restore/

  # Force overwrite
  $0 --backup /mnt/backups/full-backup-*.tar.gz \\
     --restore --file /home/user --force --dest /home/

EOF
  exit 0
}

validate_backup() {
  if [ -z "$BACKUP_FILE" ]; then
    log ERROR "Backup file not specified"
    exit 1
  fi

  if [ ! -f "$BACKUP_FILE" ]; then
    log ERROR "Backup file not found: $BACKUP_FILE"
    exit 1
  fi

  log INFO "Backup file: $BACKUP_FILE"
  log INFO "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
}

get_tar_options() {
  local backup_file=$1
  local tar_opts=""

  # Detect compression based on file extension
  case "$backup_file" in
    *.tar.gz)
      tar_opts="-z"
      ;;
    *.tar.bz2)
      tar_opts="-j"
      ;;
    *.tar.xz)
      tar_opts="-J"
      ;;
    *.tar)
      tar_opts=""
      ;;
    *)
      log WARNING "Unknown compression format, attempting auto-detection"
      tar_opts="-a"  # Auto-detect compression
      ;;
  esac

  echo "$tar_opts"
}

list_backup() {
  log INFO "Listing backup contents..."

  local tar_opts=$(get_tar_options "$BACKUP_FILE")

  tar ${tar_opts} -tf "$BACKUP_FILE" 2>/dev/null | head -50

  local total_files=$(tar ${tar_opts} -tf "$BACKUP_FILE" 2>/dev/null | wc -l)
  echo ""
  log INFO "Total files in backup: $total_files (showing first 50)"

  # Show key directories
  echo ""
  log INFO "Key directories backed up:"
  tar ${tar_opts} -tf "$BACKUP_FILE" 2>/dev/null | grep -E '^(etc|home|var|usr|opt)/' | cut -d'/' -f1 | sort -u
}

restore_file() {
  if [ -z "$FILE_TO_RESTORE" ] && [ "$ACTION" != "restore-all" ]; then
    log ERROR "File to restore not specified"
    exit 1
  fi

  # Create destination directory if it doesn't exist
  if [ ! -d "$RESTORE_DEST" ]; then
    log INFO "Creating destination directory: $RESTORE_DEST"
    mkdir -p "$RESTORE_DEST"
  fi

  local tar_opts=$(get_tar_options "$BACKUP_FILE")

  log INFO "Restoring to: $RESTORE_DEST"

  if [ "$ACTION" = "restore-all" ]; then
    log INFO "Restoring entire backup..."

    # Restore everything
    if tar ${tar_opts} -xf "$BACKUP_FILE" -C "$RESTORE_DEST"; then
      log INFO "Full restore completed successfully"
      log INFO "Files restored to: $RESTORE_DEST"

      # Show summary
      echo ""
      log INFO "Restore summary:"
      find "$RESTORE_DEST" -type f | wc -l | xargs echo "  Total files:"
      du -sh "$RESTORE_DEST" | xargs echo "  Total size:"

      return 0
    else
      log ERROR "Full restore failed"
      return 1
    fi
  else
    # Restore specific file
    log INFO "Searching for: $FILE_TO_RESTORE"

    # Check if file exists in backup
    local tar_opts=$(get_tar_options "$BACKUP_FILE")
    if ! tar ${tar_opts} -tf "$BACKUP_FILE" 2>/dev/null | grep -q "$FILE_TO_RESTORE"; then
      log WARNING "File not found in backup: $FILE_TO_RESTORE"
      log INFO "Searching for similar files..."
      tar ${tar_opts} -tf "$BACKUP_FILE" 2>/dev/null | grep "$(basename "$FILE_TO_RESTORE")" | head -10
      return 1
    fi

    # Restore the specific file
    log INFO "Restoring file: $FILE_TO_RESTORE"

    if tar ${tar_opts} -xf "$BACKUP_FILE" -C "$RESTORE_DEST" "$FILE_TO_RESTORE"; then
      log INFO "File restored successfully"

      # Show where it was restored
      local restored_path="$RESTORE_DEST/$FILE_TO_RESTORE"
      if [ -e "$restored_path" ]; then
        if [ -f "$restored_path" ]; then
          log INFO "Restored file location: $restored_path"
          log INFO "Restored file size: $(du -h "$restored_path" | cut -f1)"
        elif [ -d "$restored_path" ]; then
          log INFO "Restored directory location: $restored_path"
          log INFO "Restored directory size: $(du -sh "$restored_path" | cut -f1)"
          log INFO "Files in directory: $(find "$restored_path" -type f | wc -l)"
        fi
      fi

      return 0
    else
      log ERROR "File restore failed"
      return 1
    fi
  fi
}

verify_restore() {
  log INFO "Verifying restored files..."

  if [ ! -d "$RESTORE_DEST" ]; then
    log WARNING "Restore destination does not exist"
    return 1
  fi

  # Check file count
  local file_count=$(find "$RESTORE_DEST" -type f | wc -l)
  log INFO "Files verified: $file_count"

  # Check directory structure
  local dir_count=$(find "$RESTORE_DEST" -type d | wc -l)
  log INFO "Directories verified: $dir_count"

  # Check total size
  local total_size=$(du -sh "$RESTORE_DEST" | cut -f1)
  log INFO "Total restored size: $total_size"

  return 0
}

# === MAIN ===

main() {
  log INFO "Restore Manager started"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --backup)
        BACKUP_FILE="$2"
        shift 2
        ;;
      --list)
        ACTION="list"
        shift
        ;;
      --restore)
        ACTION="restore"
        shift
        ;;
      --file)
        FILE_TO_RESTORE="$2"
        shift 2
        ;;
      --all)
        ACTION="restore-all"
        shift
        ;;
      --dest)
        RESTORE_DEST="$2"
        shift 2
        ;;
      --force)
        FORCE=true
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

  # Validate backup file
  validate_backup

  # Execute action
  case $ACTION in
    list)
      list_backup
      ;;
    restore)
      restore_file
      verify_restore
      ;;
    restore-all)
      restore_file
      verify_restore
      ;;
    *)
      log ERROR "Unknown action: $ACTION"
      exit 1
      ;;
  esac
}

main "$@"
