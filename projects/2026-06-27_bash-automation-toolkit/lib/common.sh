#!/bin/bash
# lib/common.sh - Common functions for DevOps scripts
# Provides: logging, color output, error handling, validation

set -euo pipefail

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file location (can be overridden)
LOGFILE="${LOGFILE:-/tmp/devops.log}"

# ===== LOGGING FUNCTIONS =====

log_info() {
  local msg="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "${BLUE}[${timestamp}]${NC} ℹ️  INFO: $msg" | tee -a "$LOGFILE"
}

log_success() {
  local msg="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "${GREEN}[${timestamp}]${NC} ✅ SUCCESS: $msg" | tee -a "$LOGFILE"
}

log_warning() {
  local msg="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "${YELLOW}[${timestamp}]${NC} ⚠️  WARNING: $msg" | tee -a "$LOGFILE"
}

log_error() {
  local msg="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "${RED}[${timestamp}]${NC} ❌ ERROR: $msg" >&2 | tee -a "$LOGFILE"
  return 1
}

log_debug() {
  local msg="$1"
  if [[ "${DEBUG:-0}" == "1" ]]; then
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[${timestamp}]${NC} 🐛 DEBUG: $msg" | tee -a "$LOGFILE"
  fi
}

# ===== OUTPUT HELPERS =====

print_header() {
  local text="$1"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${BLUE}${text}${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_section() {
  local text="$1"
  echo ""
  echo -e "${BLUE}▶ ${text}${NC}"
}

# ===== COMMAND UTILITIES =====

# Check if command exists
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    log_error "Required command not found: $cmd"
    return 1
  fi
}

# Check if file exists and is readable
require_file() {
  local file="$1"
  if [[ ! -r "$file" ]]; then
    log_error "File not found or not readable: $file"
    return 1
  fi
}

# Check if directory exists and is writable
require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    log_error "Directory not found: $dir"
    return 1
  fi
  if [[ ! -w "$dir" ]]; then
    log_error "Directory not writable: $dir"
    return 1
  fi
}

# ===== VALIDATION FUNCTIONS =====

# Check if variable is set and not empty
require_var() {
  local var_name="$1"
  local var_value="${!var_name:-}"

  if [[ -z "$var_value" ]]; then
    log_error "Required variable not set: $var_name"
    return 1
  fi
}

# Validate integer
is_integer() {
  local value="$1"
  if ! [[ "$value" =~ ^[0-9]+$ ]]; then
    log_error "Not a valid integer: $value"
    return 1
  fi
}

# Validate percentage (0-100)
is_percentage() {
  local value="$1"
  if ! [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" -lt 0 ]] || [[ "$value" -gt 100 ]]; then
    log_error "Not a valid percentage (0-100): $value"
    return 1
  fi
}

# ===== FILE OPERATIONS =====

# Safe temporary file creation
create_tmpfile() {
  local tmpfile
  tmpfile=$(mktemp) || {
    log_error "Failed to create temporary file"
    return 1
  }
  echo "$tmpfile"
}

# Safe temporary directory
create_tmpdir() {
  local tmpdir
  tmpdir=$(mktemp -d) || {
    log_error "Failed to create temporary directory"
    return 1
  }
  echo "$tmpdir"
}

# Backup a file with timestamp
backup_file() {
  local file="$1"
  local backup_dir="${2:-.}"

  if [[ ! -f "$file" ]]; then
    log_error "File does not exist: $file"
    return 1
  fi

  local filename
  filename=$(basename "$file")
  local timestamp
  timestamp=$(date +%s)
  local backup_file="$backup_dir/${filename}.bak.${timestamp}"

  if cp "$file" "$backup_file"; then
    log_info "Backup created: $backup_file"
    echo "$backup_file"
  else
    log_error "Failed to backup file: $file"
    return 1
  fi
}

# ===== SYSTEM INFORMATION =====

# Get CPU count
get_cpu_count() {
  nproc 2>/dev/null || echo "1"
}

# Get total memory in MB
get_total_memory_mb() {
  local mem
  mem=$(grep MemTotal /proc/meminfo | awk '{print int($2 / 1024)}')
  echo "$mem"
}

# Get free memory in MB
get_free_memory_mb() {
  local mem
  mem=$(grep MemAvailable /proc/meminfo | awk '{print int($2 / 1024)}')
  echo "$mem"
}

# Get disk usage percentage
get_disk_usage_percent() {
  local path="${1:-.}"
  df "$path" | tail -1 | awk '{print int($5)}'
}

# ===== PROGRESS INDICATORS =====

# Simple progress bar
progress_bar() {
  local current="$1"
  local total="$2"
  local width="${3:-20}"

  local percentage=$((current * 100 / total))
  local filled=$((percentage * width / 100))

  printf "["
  printf "%${filled}s" | tr ' ' '█'
  printf "%$((width - filled))s" | tr ' ' '░'
  printf "] %3d%%" "$percentage"
}

# ===== PERFORMANCE =====

# Measure execution time
measure_time() {
  local start_time
  start_time=$(date +%s%N)

  # Run the command
  "$@"
  local exit_code=$?

  local end_time
  end_time=$(date +%s%N)
  local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to ms

  log_info "Execution time: ${duration}ms"
  return $exit_code
}

# ===== UTILITY FUNCTIONS =====

# Retry a command up to N times
retry() {
  local max_attempts="$1"
  shift
  local attempt=1

  while [[ $attempt -le $max_attempts ]]; do
    log_debug "Attempt $attempt/$max_attempts: $*"

    if "$@"; then
      return 0
    fi

    if [[ $attempt -lt $max_attempts ]]; then
      local wait_time=$((2 ** (attempt - 1)))
      log_warning "Command failed. Retrying in ${wait_time}s..."
      sleep "$wait_time"
    fi

    ((attempt++))
  done

  log_error "Command failed after $max_attempts attempts: $*"
  return 1
}

# Confirm action with user
confirm() {
  local prompt="${1:-Continue?}"
  local response

  read -p "${prompt} (yes/no): " response
  [[ "$response" =~ ^[Yy][Ee][Ss]?$ ]]
}

# ===== CLEANUP =====

# Global cleanup handler (can be extended by sourcing scripts)
declare -a CLEANUP_FUNCTIONS=()

on_exit() {
  local exit_code=$?

  log_debug "Running cleanup handlers..."
  for cleanup_fn in "${CLEANUP_FUNCTIONS[@]}"; do
    if declare -f "$cleanup_fn" >/dev/null; then
      log_debug "Calling cleanup function: $cleanup_fn"
      "$cleanup_fn" || true
    fi
  done

  if [[ $exit_code -eq 0 ]]; then
    log_success "Operation completed successfully"
  else
    log_error "Operation failed with exit code: $exit_code"
  fi

  exit $exit_code
}

# Register cleanup function to be called on exit
register_cleanup() {
  local fn="$1"
  CLEANUP_FUNCTIONS+=("$fn")
}

# Set up exit trap
trap on_exit EXIT ERR INT TERM

export -f log_info log_success log_warning log_error log_debug
export -f print_header print_section
export -f require_command require_file require_dir require_var
export -f is_integer is_percentage
export -f create_tmpfile create_tmpdir backup_file
export -f get_cpu_count get_total_memory_mb get_free_memory_mb get_disk_usage_percent
export -f progress_bar measure_time retry confirm
export -f register_cleanup on_exit
