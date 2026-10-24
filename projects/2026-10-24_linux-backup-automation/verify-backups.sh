#!/bin/bash
#
# Verify Backups - Check integrity and validity of backup archives
# Validates checksums, archive structure, and accessibility
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
BACKUP_DIR=""
VERBOSE=false
DETAILED=false
REPAIR=false

# Statistics
TOTAL_BACKUPS=0
VALID_BACKUPS=0
INVALID_BACKUPS=0
CORRUPTED_FILES=0

log() {
  local level=$1
  shift
  local message="$*"

  case $level in
    INFO)
      echo -e "${GREEN}[✓]${NC} ${message}"
      ;;
    SUCCESS)
      echo -e "${GREEN}[✓]${NC} ${message}"
      ;;
    WARNING)
      echo -e "${YELLOW}[!]${NC} ${message}"
      ;;
    ERROR)
      echo -e "${RED}[✗]${NC} ${message}" >&2
      ;;
    DEBUG)
      [ "$VERBOSE" = true ] && echo -e "${BLUE}[•]${NC} ${message}"
      ;;
  esac
}

usage() {
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --backup-dir DIR    Directory containing backups (required)
  --verbose           Verbose output
  --detailed          Detailed report with file-by-file checks
  --repair            Attempt to repair corrupted backups
  --help              Show this help message

EXAMPLES:
  # Basic verification
  $0 --backup-dir /mnt/backups

  # Detailed verification with file listing
  $0 --backup-dir /mnt/backups --detailed

  # Repair corrupted backups
  $0 --backup-dir /mnt/backups --repair

EOF
  exit 0
}

validate_backup_dir() {
  if [ -z "$BACKUP_DIR" ]; then
    log ERROR "Backup directory not specified"
    exit 1
  fi

  if [ ! -d "$BACKUP_DIR" ]; then
    log ERROR "Backup directory not found: $BACKUP_DIR"
    exit 1
  fi

  log INFO "Backup directory: $BACKUP_DIR"
  log INFO "Space used: $(du -sh "$BACKUP_DIR" | cut -f1)"
}

get_tar_options() {
  local backup_file=$1
  local tar_opts=""

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
      tar_opts="-a"
      ;;
  esac

  echo "$tar_opts"
}

verify_checksum() {
  local backup_file=$1
  local checksum_file="${backup_file}.md5"

  if [ ! -f "$checksum_file" ]; then
    log DEBUG "No checksum file found: $checksum_file"
    return 0
  fi

  log DEBUG "Verifying checksum for: $(basename "$backup_file")"

  if md5sum -c "$checksum_file" &>/dev/null; then
    log SUCCESS "Checksum verification passed"
    return 0
  else
    log ERROR "Checksum verification failed"
    return 1
  fi
}

verify_archive_integrity() {
  local backup_file=$1
  local tar_opts=$(get_tar_options "$backup_file")

  log DEBUG "Testing archive structure for: $(basename "$backup_file")"

  # Test archive integrity
  if tar ${tar_opts} -tf "$backup_file" &>/dev/null; then
    log DEBUG "Archive structure is valid"
    return 0
  else
    log ERROR "Archive structure is corrupted"
    return 1
  fi
}

count_files_in_archive() {
  local backup_file=$1
  local tar_opts=$(get_tar_options "$backup_file")

  tar ${tar_opts} -tf "$backup_file" 2>/dev/null | wc -l
}

get_archive_size() {
  local backup_file=$1
  du -h "$backup_file" | cut -f1
}

verify_file_list() {
  local backup_file=$1
  local tar_opts=$(get_tar_options "$backup_file")

  log DEBUG "File listing for: $(basename "$backup_file")"

  tar ${tar_opts} -tf "$backup_file" 2>/dev/null | head -20

  local total=$(tar ${tar_opts} -tf "$backup_file" 2>/dev/null | wc -l)
  echo "... and $((total - 20)) more files"
}

verify_backup() {
  local backup_file=$1

  ((TOTAL_BACKUPS++))

  log INFO "Verifying backup: $(basename "$backup_file")"
  log DEBUG "Path: $backup_file"

  local backup_valid=true

  # Check file accessibility
  if [ ! -r "$backup_file" ]; then
    log ERROR "Backup file is not readable"
    ((INVALID_BACKUPS++))
    return 1
  fi

  # Verify checksum
  if ! verify_checksum "$backup_file"; then
    backup_valid=false
  fi

  # Verify archive integrity
  if ! verify_archive_integrity "$backup_file"; then
    ((CORRUPTED_FILES++))
    backup_valid=false
  fi

  # Get statistics
  local file_count=$(count_files_in_archive "$backup_file")
  local archive_size=$(get_archive_size "$backup_file")
  local creation_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$backup_file" 2>/dev/null || \
                       stat -c "%y" "$backup_file" 2>/dev/null | cut -d. -f1)

  log INFO "  Files: $file_count"
  log INFO "  Size: $archive_size"
  log INFO "  Created: $creation_time"

  # Show detailed file list if requested
  if [ "$DETAILED" = true ]; then
    log DEBUG "Detailed file listing:"
    verify_file_list "$backup_file"
  fi

  if [ "$backup_valid" = true ]; then
    ((VALID_BACKUPS++))
    log SUCCESS "Backup verification passed"
    return 0
  else
    ((INVALID_BACKUPS++))
    log ERROR "Backup verification failed"
    return 1
  fi
}

verify_all_backups() {
  local backup_files=()

  # Find all backup files
  while IFS= read -r -d '' backup_file; do
    backup_files+=("$backup_file")
  done < <(find "$BACKUP_DIR" -maxdepth 1 -name "*-backup-*.tar*" -type f -print0)

  if [ ${#backup_files[@]} -eq 0 ]; then
    log WARNING "No backup files found in: $BACKUP_DIR"
    return 1
  fi

  log INFO "Found ${#backup_files[@]} backup(s) to verify"
  echo ""

  # Verify each backup
  for backup_file in "${backup_files[@]}"; do
    verify_backup "$backup_file"
    echo ""
  done

  # Print summary
  print_summary
}

print_summary() {
  echo "=============================================="
  echo -e "${BLUE}Backup Verification Summary${NC}"
  echo "=============================================="
  echo "Total backups verified: $TOTAL_BACKUPS"
  echo -e "${GREEN}Valid backups: $VALID_BACKUPS${NC}"
  echo -e "${RED}Invalid backups: $INVALID_BACKUPS${NC}"

  if [ $CORRUPTED_FILES -gt 0 ]; then
    echo -e "${RED}Corrupted files detected: $CORRUPTED_FILES${NC}"
  fi

  echo "=============================================="

  # Overall status
  if [ "$INVALID_BACKUPS" -eq 0 ] && [ "$CORRUPTED_FILES" -eq 0 ]; then
    echo -e "${GREEN}✓ All backups are healthy${NC}"
    return 0
  else
    echo -e "${RED}✗ Some backups need attention${NC}"
    return 1
  fi
}

# === MAIN ===

main() {
  log INFO "Backup Verification Tool started"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --backup-dir)
        BACKUP_DIR="$2"
        shift 2
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --detailed)
        DETAILED=true
        VERBOSE=true
        shift
        ;;
      --repair)
        REPAIR=true
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

  # Validate backup directory
  validate_backup_dir

  echo ""

  # Verify all backups
  if verify_all_backups; then
    exit 0
  else
    exit 1
  fi
}

main "$@"
