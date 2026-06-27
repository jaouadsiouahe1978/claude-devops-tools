#!/bin/bash
# scripts/cleanup-old-files.sh
# Safe disk cleanup by removing old files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

DIRECTORIES=()
DAYS=30
MIN_SIZE=0
DRY_RUN=0
INTERACTIVE=1

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS] DIRECTORY [DIRECTORY...]

Safely remove old files to free disk space.

OPTIONS:
  --days DAYS         Delete files older than N days (default: 30)
  --min-size SIZE     Only delete files larger than SIZE (e.g., 1M, 100K)
  --dry-run          Show what would be deleted, don't actually delete
  --force            Don't ask for confirmation
  --help             Show this help

EXAMPLES:
  $0 /tmp /var/tmp                    # Clean default locations
  $0 --days 7 /var/log                # Clean recent logs
  $0 --min-size 10M --dry-run /cache  # Preview large old files

EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      DAYS="$2"
      is_integer "$DAYS" || exit 1
      shift 2
      ;;
    --min-size)
      MIN_SIZE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --force)
      INTERACTIVE=0
      shift
      ;;
    --help)
      show_usage
      exit 0
      ;;
    -*)
      log_error "Unknown option: $1"
      exit 1
      ;;
    *)
      DIRECTORIES+=("$1")
      shift
      ;;
  esac
done

if [[ ${#DIRECTORIES[@]} -eq 0 ]]; then
  log_error "No directories specified"
  show_usage
  exit 1
fi

# Convert size to bytes
convert_size() {
  local size="$1"
  [[ $size == "0" ]] && echo 0 && return
  case "${size: -1}" in
    K|k) echo "$((${size%?} * 1024))" ;;
    M|m) echo "$((${size%?} * 1024 * 1024))" ;;
    G|g) echo "$((${size%?} * 1024 * 1024 * 1024))" ;;
    *) echo "$size" ;;
  esac
}

min_size_bytes=$(convert_size "$MIN_SIZE")

print_header "FILE CLEANUP MANAGER"
log_info "Age threshold: $DAYS days"
[[ $MIN_SIZE != "0" ]] && log_info "Min file size: $MIN_SIZE"
log_info "Directories: ${#DIRECTORIES[@]}"

# Find files to delete
declare -a TO_DELETE=()
total_size=0

for dir in "${DIRECTORIES[@]}"; do
  if [[ ! -d "$dir" ]]; then
    log_warning "Directory not found: $dir"
    continue
  fi

  log_info "Scanning: $dir"

  while IFS= read -r -d '' file; do
    local file_size
    file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)

    if [[ $file_size -ge $min_size_bytes ]]; then
      TO_DELETE+=("$file")
      total_size=$((total_size + file_size))
    fi
  done < <(find "$dir" -type f -mtime +$DAYS -print0 2>/dev/null)
done

if [[ ${#TO_DELETE[@]} -eq 0 ]]; then
  log_info "No files matching criteria"
  exit 0
fi

print_section "Files to delete: ${#TO_DELETE[@]}"
log_warning "Total size: $((total_size / 1024 / 1024)) MB"

# Show preview
local_count=0
for file in "${TO_DELETE[@]}"; do
  if [[ $local_count -lt 10 ]]; then
    local size
    size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    echo "  - $(basename "$file") ($((size / 1024)) KB)"
    ((local_count++))
  fi
done

if [[ ${#TO_DELETE[@]} -gt 10 ]]; then
  echo "  ... and $((${#TO_DELETE[@]} - 10)) more files"
fi

echo ""

# Confirmation
if [[ $INTERACTIVE -eq 1 ]]; then
  if ! confirm "Delete these files?"; then
    log_warning "Cancelled by user"
    exit 0
  fi
fi

# Delete
if [[ $DRY_RUN -eq 1 ]]; then
  log_info "[DRY-RUN] Would delete ${#TO_DELETE[@]} files"
else
  print_section "Deleting files..."
  deleted_count=0
  freed_size=0

  for file in "${TO_DELETE[@]}"; do
    if rm -f "$file"; then
      local size
      size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
      ((deleted_count++))
      freed_size=$((freed_size + size))

      if [[ $((deleted_count % 50)) -eq 0 ]]; then
        log_debug "Deleted $deleted_count files..."
      fi
    else
      log_warning "Failed to delete: $file"
    fi
  done

  print_header "CLEANUP COMPLETE"
  log_success "Deleted: $deleted_count file(s)"
  log_info "Space freed: $((freed_size / 1024 / 1024)) MB"
fi
