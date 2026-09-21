#!/bin/bash
set -euo pipefail

# Cleanup Script
# Manages backup rotation and disk space

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Configuration file not found: $CONFIG_FILE" >&2
  exit 1
fi
source "$CONFIG_FILE"

# Display disk usage
show_disk_usage() {
  if [[ ! -d "$BACKUP_DEST" ]]; then
    echo "ERROR: Backup destination not found: $BACKUP_DEST"
    return 1
  fi

  local total_size=$(du -sh "$BACKUP_DEST" | cut -f1)
  local file_count=$(find "$BACKUP_DEST" -name "${BACKUP_PREFIX}-*.tar*" | wc -l)

  echo "Backup Storage Information"
  echo "==========================================="
  echo "Location: ${BACKUP_DEST}"
  echo "Total size: ${total_size}"
  echo "File count: ${file_count}"
  echo "Available space: $(df -h "$BACKUP_DEST" | awk 'NR==2 {print $4}')"
}

# Clean old backups based on retention policy
cleanup_by_retention() {
  echo "Cleaning backups by retention policy..."
  echo "==========================================="

  if [[ ! -d "$BACKUP_DEST" ]]; then
    echo "ERROR: Backup destination not found"
    return 1
  fi

  local current_time=$(date +%s)
  local deleted_count=0
  local freed_space=0

  for backup_file in "${BACKUP_DEST}"/${BACKUP_PREFIX}-*.tar*; do
    if [[ ! -f "$backup_file" ]]; then
      continue
    fi

    local file_time=$(stat -c %Y "$backup_file" 2>/dev/null || stat -f %m "$backup_file" 2>/dev/null)
    local file_age=$((current_time - file_time))
    local filename=$(basename "$backup_file")

    # Determine retention period based on backup type
    local retention_sec=$((RETENTION_DAILY * 86400))

    if [[ "$filename" == *"weekly"* ]]; then
      retention_sec=$((RETENTION_WEEKLY * 86400))
    elif [[ "$filename" == *"monthly"* ]]; then
      retention_sec=$((RETENTION_MONTHLY * 86400))
    fi

    # Delete if exceeds retention period
    if [[ $file_age -gt $retention_sec ]]; then
      local file_size=$(du -b "$backup_file" | cut -f1)

      if rm -f "$backup_file"; then
        echo "Deleted: ${filename}"
        echo "  Age: $(( file_age / 86400 )) days"
        echo "  Size: $(( file_size / 1024 / 1024 )) MB"
        ((deleted_count++))
        freed_space=$((freed_space + file_size))
      else
        echo "ERROR: Failed to delete: $filename"
      fi
    fi
  done

  echo ""
  echo "Summary: Deleted ${deleted_count} backups"
  echo "Freed space: $(( freed_space / 1024 / 1024 )) MB"
}

# Verify all backup integrity
verify_all_backups() {
  echo "Verifying all backups integrity..."
  echo "==========================================="

  local total_count=0
  local valid_count=0
  local corrupt_count=0

  for backup_file in "${BACKUP_DEST}"/${BACKUP_PREFIX}-*.tar*; do
    if [[ ! -f "$backup_file" ]]; then
      continue
    fi

    ((total_count++))
    local filename=$(basename "$backup_file")

    if tar -tzf "$backup_file" > /dev/null 2>&1; then
      ((valid_count++))
      echo "✓ ${filename}"
    else
      ((corrupt_count++))
      echo "✗ ${filename} (CORRUPT)"
    fi
  done

  echo ""
  echo "Summary:"
  echo "  Total: ${total_count}"
  echo "  Valid: ${valid_count}"
  echo "  Corrupt: ${corrupt_count}"
}

# Show help
show_help() {
  cat << EOF
Backup cleanup and maintenance utility

Usage: cleanup.sh [COMMAND]

Commands:
  retention       Clean old backups by retention policy
  verify          Verify integrity of all backups
  disk-usage      Show disk usage information
  all             Run all cleanup operations
  help            Show this help message

EOF
}

# Main execution
main() {
  local command="${1:-all}"

  case "$command" in
    retention)
      cleanup_by_retention
      ;;
    verify)
      verify_all_backups
      ;;
    disk-usage)
      show_disk_usage
      ;;
    all)
      show_disk_usage
      echo ""
      cleanup_by_retention
      echo ""
      verify_all_backups
      ;;
    help)
      show_help
      ;;
    *)
      echo "Unknown command: $command" >&2
      show_help
      exit 1
      ;;
  esac
}

main "$@"
