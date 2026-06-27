#!/bin/bash
# scripts/log-rotation-manager.sh
# Intelligent log rotation without logrotate

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

LOG_DIR="/var/log"
PATTERN="*.log"
SIZE_LIMIT="100M"
KEEP_DAYS=7
COMPRESS=1

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Rotate logs based on size and age.

OPTIONS:
  --dir DIR          Log directory to scan (default: /var/log)
  --pattern GLOB     File pattern to match (default: *.log)
  --size SIZE        Size limit (e.g., 100M, 1G, default: 100M)
  --keep DAYS        Keep logs for N days (default: 7)
  --no-compress      Don't compress rotated logs
  --dry-run         Show what would be done
  --help            Show this help

EXAMPLES:
  $0 --dir /var/log/app --size 50M
  $0 --dir /tmp --keep 14 --dry-run

EOF
}

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) LOG_DIR="$2"; shift 2 ;;
    --pattern) PATTERN="$2"; shift 2 ;;
    --size) SIZE_LIMIT="$2"; shift 2 ;;
    --keep) KEEP_DAYS="$2"; shift 2 ;;
    --no-compress) COMPRESS=0; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help) show_usage; exit 0 ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

# Convert size to bytes
convert_size_to_bytes() {
  local size="$1"
  case "${size: -1}" in
    K|k) echo "$((${size%?} * 1024))" ;;
    M|m) echo "$((${size%?} * 1024 * 1024))" ;;
    G|g) echo "$((${size%?} * 1024 * 1024 * 1024))" ;;
    *) echo "$size" ;;
  esac
}

size_bytes=$(convert_size_to_bytes "$SIZE_LIMIT")

print_header "LOG ROTATION MANAGER"
log_info "Scanning: $LOG_DIR"
log_info "Pattern: $PATTERN"
log_info "Size limit: $SIZE_LIMIT"
log_info "Retention: $KEEP_DAYS days"

# Scan and rotate
rotated_count=0
total_freed=0

while IFS= read -r logfile; do
  [[ -f "$logfile" ]] || continue

  local file_size
  file_size=$(stat -c%s "$logfile" 2>/dev/null || stat -f%z "$logfile" 2>/dev/null)

  if [[ $file_size -gt $size_bytes ]]; then
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local rotated="${logfile}.${timestamp}"

    if [[ $DRY_RUN -eq 0 ]]; then
      log_info "Rotating: $(basename "$logfile") (${file_size} bytes)"
      mv "$logfile" "$rotated"

      if [[ $COMPRESS -eq 1 ]]; then
        gzip "$rotated"
        rotated="${rotated}.gz"
      fi

      # Touch new log file if it's part of a live app
      touch "$logfile"

      total_freed=$((total_freed + file_size))
      ((rotated_count++))
    else
      log_info "[DRY-RUN] Would rotate: $(basename "$logfile") (${file_size} bytes)"
    fi
  fi
done < <(find "$LOG_DIR" -maxdepth 1 -name "$PATTERN" -type f 2>/dev/null)

# Cleanup old files
cleanup_count=0
cutoff_time=$(date -d "$KEEP_DAYS days ago" +%s 2>/dev/null || \
              date -v-${KEEP_DAYS}d +%s 2>/dev/null || \
              date -j -v-${KEEP_DAYS}d +%s 2>/dev/null)

while IFS= read -r -d '' file; do
  local mtime
  mtime=$(stat -c%Y "$file" 2>/dev/null || stat -f%m "$file" 2>/dev/null)

  if [[ $mtime -lt $cutoff_time ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      log_info "Deleting old: $(basename "$file")"
      rm -f "$file"
      ((cleanup_count++))
    else
      log_info "[DRY-RUN] Would delete: $(basename "$file")"
    fi
  fi
done < <(find "$LOG_DIR" -maxdepth 1 \( -name "${PATTERN}.*.gz" -o -name "${PATTERN}.*" \) -print0 2>/dev/null)

print_header "ROTATION SUMMARY"
log_info "Rotated: $rotated_count file(s)"
log_info "Cleaned: $cleanup_count old file(s)"
log_info "Space freed: $((total_freed / 1024 / 1024)) MB"

if [[ $DRY_RUN -eq 0 ]]; then
  log_success "Log rotation completed"
fi
