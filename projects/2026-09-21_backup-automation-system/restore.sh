#!/bin/bash
set -euo pipefail

# Restore Script
# Provides utilities to list, verify, and restore from backups

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Configuration file not found: $CONFIG_FILE" >&2
  exit 1
fi
source "$CONFIG_FILE"

# Display help message
show_help() {
  cat << EOF
Restore utility for automated backups

Usage: restore.sh [OPTIONS] BACKUP_FILE

Options:
  --list               List contents of backup file
  --verify             Verify backup integrity
  --extract            Extract backup to specified directory
  --extract-single     Extract single file from backup
  --help               Show this help message

Examples:
  restore.sh --list /opt/backups/archives/backup-daily-2026-09-21-02-00-00.tar.gz
  restore.sh --verify /opt/backups/archives/backup-daily-2026-09-21-02-00-00.tar.gz
  restore.sh --extract /opt/backups/archives/backup-daily-2026-09-21-02-00-00.tar.gz /tmp/restore
  restore.sh --extract-single /opt/backups/archives/backup-daily-2026-09-21-02-00-00.tar.gz /etc/passwd /tmp/

EOF
}

# List backup contents
list_backup() {
  local backup_file="$1"

  if [[ ! -f "$backup_file" ]]; then
    echo "ERROR: Backup file not found: $backup_file" >&2
    return 1
  fi

  echo "Listing contents of: $backup_file"
  echo "==========================================="
  tar -tzf "$backup_file" | head -50
  echo ""
  echo "Total files: $(tar -tzf "$backup_file" | wc -l)"
}

# Verify backup integrity
verify_backup() {
  local backup_file="$1"

  if [[ ! -f "$backup_file" ]]; then
    echo "ERROR: Backup file not found: $backup_file" >&2
    return 1
  fi

  echo "Verifying backup: $backup_file"

  if tar -tzf "$backup_file" > /dev/null 2>&1; then
    echo "✓ Backup verification: PASSED"
    echo "✓ File size: $(du -h "$backup_file" | cut -f1)"
    echo "✓ Modified: $(date -r "$backup_file")"
    return 0
  else
    echo "✗ Backup verification: FAILED"
    return 1
  fi
}

# Extract entire backup
extract_backup() {
  local backup_file="$1"
  local restore_dir="$2"

  if [[ ! -f "$backup_file" ]]; then
    echo "ERROR: Backup file not found: $backup_file" >&2
    return 1
  fi

  if [[ ! -d "$restore_dir" ]]; then
    echo "Creating restore directory: $restore_dir"
    mkdir -p "$restore_dir"
  fi

  echo "Extracting backup to: $restore_dir"
  echo "This may take several minutes..."

  if tar -xzf "$backup_file" -C "$restore_dir"; then
    echo "✓ Backup extracted successfully"
    echo "✓ Restored to: $restore_dir"
    echo "✓ Total size: $(du -sh "$restore_dir" | cut -f1)"
    return 0
  else
    echo "✗ Backup extraction failed"
    return 1
  fi
}

# Extract single file from backup
extract_single_file() {
  local backup_file="$1"
  local file_path="$2"
  local restore_dir="$3"

  if [[ ! -f "$backup_file" ]]; then
    echo "ERROR: Backup file not found: $backup_file" >&2
    return 1
  fi

  if [[ ! -d "$restore_dir" ]]; then
    echo "Creating restore directory: $restore_dir"
    mkdir -p "$restore_dir"
  fi

  # Remove leading slash from file path for tar
  local tar_path="${file_path#/}"

  echo "Extracting file: $file_path"

  if tar -xzf "$backup_file" -C "$restore_dir" "$tar_path" 2>/dev/null; then
    echo "✓ File extracted successfully"
    echo "✓ Restored to: ${restore_dir}/${tar_path}"
    return 0
  else
    echo "✗ File extraction failed (file may not exist in backup)"
    return 1
  fi
}

# Show backup information
show_backup_info() {
  local backup_file="$1"

  if [[ ! -f "$backup_file" ]]; then
    echo "ERROR: Backup file not found: $backup_file" >&2
    return 1
  fi

  echo "Backup Information: $(basename "$backup_file")"
  echo "==========================================="
  echo "File size: $(du -h "$backup_file" | cut -f1)"
  echo "Modified: $(date -r "$backup_file")"
  echo "File count: $(tar -tzf "$backup_file" | wc -l)"

  local file_size=$(stat -c%s "$backup_file" 2>/dev/null || stat -f%z "$backup_file" 2>/dev/null)
  echo "Compressed size: $(numfmt --to=iec $file_size 2>/dev/null || echo ${file_size} bytes)"

  echo ""
  echo "Top-level contents:"
  echo "==========================================="
  tar -tzf "$backup_file" | cut -d'/' -f1-2 | sort -u | head -20
}

# List available backups
list_available_backups() {
  echo "Available backups in: ${BACKUP_DEST}"
  echo "==========================================="

  if [[ ! -d "$BACKUP_DEST" ]]; then
    echo "ERROR: Backup destination directory not found"
    return 1
  fi

  local count=0
  ls -lhS "${BACKUP_DEST}"/${BACKUP_PREFIX}*.tar* 2>/dev/null | while read -r line; do
    echo "$line"
    ((count++))
  done

  if [[ -L "${BACKUP_DEST}/latest.tar"* ]]; then
    echo ""
    echo "Latest backup (symlink):"
    ls -l "${BACKUP_DEST}"/latest.tar* 2>/dev/null
  fi
}

# Main execution
main() {
  if [[ $# -lt 1 ]]; then
    show_help
    exit 1
  fi

  local action="$1"

  case "$action" in
    --help)
      show_help
      ;;
    --list)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: Backup file required" >&2
        exit 1
      fi
      list_backup "$2"
      ;;
    --verify)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: Backup file required" >&2
        exit 1
      fi
      verify_backup "$2"
      ;;
    --extract)
      if [[ $# -lt 3 ]]; then
        echo "ERROR: Backup file and restore directory required" >&2
        exit 1
      fi
      extract_backup "$2" "$3"
      ;;
    --extract-single)
      if [[ $# -lt 4 ]]; then
        echo "ERROR: Backup file, file path, and restore directory required" >&2
        exit 1
      fi
      extract_single_file "$2" "$3" "$4"
      ;;
    --info)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: Backup file required" >&2
        exit 1
      fi
      show_backup_info "$2"
      ;;
    --list-backups)
      list_available_backups
      ;;
    *)
      echo "Unknown action: $action" >&2
      show_help
      exit 1
      ;;
  esac
}

main "$@"
