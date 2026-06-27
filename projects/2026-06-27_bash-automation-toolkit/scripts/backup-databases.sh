#!/bin/bash
# scripts/backup-databases.sh
# Database backup script with rotation
# Usage: ./backup-databases.sh --type postgres --output /backups --retention 30

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Default values
BACKUP_TYPE="postgres"
OUTPUT_DIR="/tmp/backups"
RETENTION_DAYS=30
DB_NAME="${DB_NAME:-}"
DB_USER="${DB_USER:-postgres}"
DB_HOST="${DB_HOST:-localhost}"
COMPRESSION="gzip"

# State tracking
BACKUP_FILE=""

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Backup databases with compression and rotation.

OPTIONS:
  --type TYPE          Database type: postgres|mysql|sqlite (default: postgres)
  --output DIR         Output directory (default: /tmp/backups)
  --db-name NAME       Database name (optional, backup all if not set)
  --db-user USER       Database user (default: postgres for PG, root for MySQL)
  --db-host HOST       Database host (default: localhost)
  --retention DAYS     Keep backups for N days (default: 30)
  --dry-run            Show what would be done, don't backup
  --help               Show this help

EXAMPLES:
  $0 --type postgres --output /backups
  $0 --type mysql --db-name myapp --retention 14
  $0 --type postgres --dry-run

EOF
}

# Parse arguments
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      BACKUP_TYPE="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --db-name)
      DB_NAME="$2"
      shift 2
      ;;
    --db-user)
      DB_USER="$2"
      shift 2
      ;;
    --db-host)
      DB_HOST="$2"
      shift 2
      ;;
    --retention)
      RETENTION_DAYS="$2"
      is_integer "$RETENTION_DAYS" || exit 1
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --help)
      show_usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Cleanup function
cleanup_backup() {
  if [[ -n "$BACKUP_FILE" && -f "$BACKUP_FILE" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      rm -f "$BACKUP_FILE"
      log_debug "Cleaned up temporary backup file: $BACKUP_FILE"
    fi
  fi
}

register_cleanup cleanup_backup

# ===== VALIDATION =====

validate_setup() {
  print_section "Validating backup setup"

  # Check backup type
  case "$BACKUP_TYPE" in
    postgres|mysql|sqlite)
      log_info "Database type: $BACKUP_TYPE"
      ;;
    *)
      log_error "Unsupported database type: $BACKUP_TYPE"
      exit 1
      ;;
  esac

  # Check required commands
  case "$BACKUP_TYPE" in
    postgres)
      require_command "pg_dump" || exit 1
      ;;
    mysql)
      require_command "mysqldump" || exit 1
      ;;
  esac

  # Create output directory if needed
  if [[ ! -d "$OUTPUT_DIR" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      mkdir -p "$OUTPUT_DIR" || {
        log_error "Failed to create output directory: $OUTPUT_DIR"
        exit 1
      }
    fi
    log_info "Created output directory: $OUTPUT_DIR"
  fi

  # Check write permissions
  if [[ ! -w "$OUTPUT_DIR" ]]; then
    log_error "Output directory not writable: $OUTPUT_DIR"
    exit 1
  fi

  log_success "Validation passed"
}

# ===== POSTGRESQL BACKUP =====

backup_postgres() {
  print_section "Backing up PostgreSQL database"

  local timestamp backup_name
  timestamp=$(date +%Y%m%d_%H%M%S)
  backup_name="postgres_${DB_NAME:-all}_${timestamp}.sql"
  BACKUP_FILE="$OUTPUT_DIR/${backup_name}.gz"

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would backup PostgreSQL to: $BACKUP_FILE"
    return 0
  fi

  log_info "Starting PostgreSQL backup..."
  log_debug "Target: $DB_HOST as $DB_USER"

  local dump_file
  dump_file=$(create_tmpfile)

  if [[ -n "$DB_NAME" ]]; then
    log_info "Backing up database: $DB_NAME"
    if ! pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$dump_file" 2>/tmp/pg_dump.err; then
      log_error "PostgreSQL dump failed"
      cat /tmp/pg_dump.err >&2
      rm -f "$dump_file"
      return 1
    fi
  else
    log_info "Backing up all databases"
    if ! pg_dumpall -h "$DB_HOST" -U "$DB_USER" > "$dump_file" 2>/tmp/pg_dump.err; then
      log_error "PostgreSQL dumpall failed"
      cat /tmp/pg_dump.err >&2
      rm -f "$dump_file"
      return 1
    fi
  fi

  # Verify dump is not empty
  local dump_size
  dump_size=$(stat -f%z "$dump_file" 2>/dev/null || stat -c%s "$dump_file" 2>/dev/null || echo 0)

  if [[ $dump_size -lt 1000 ]]; then
    log_error "Backup too small (likely empty): $dump_size bytes"
    rm -f "$dump_file"
    return 1
  fi

  # Compress
  log_info "Compressing backup... (size: $((dump_size / 1024)) KB)"
  if gzip -f "$dump_file"; then
    log_success "Backup created: $BACKUP_FILE"
    local final_size
    final_size=$(stat -f%z "$BACKUP_FILE" 2>/dev/null || stat -c%s "$BACKUP_FILE" 2>/dev/null)
    log_info "Compressed size: $((final_size / 1024)) KB"
  else
    log_error "Compression failed"
    return 1
  fi
}

# ===== MYSQL BACKUP =====

backup_mysql() {
  print_section "Backing up MySQL database"

  local timestamp backup_name
  timestamp=$(date +%Y%m%d_%H%M%S)
  backup_name="mysql_${DB_NAME:-all}_${timestamp}.sql"
  BACKUP_FILE="$OUTPUT_DIR/${backup_name}.gz"

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would backup MySQL to: $BACKUP_FILE"
    return 0
  fi

  log_info "Starting MySQL backup..."

  local dump_file
  dump_file=$(create_tmpfile)

  if [[ -n "$DB_NAME" ]]; then
    log_info "Backing up database: $DB_NAME"
    if ! mysqldump -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" > "$dump_file" 2>/tmp/mysqldump.err; then
      log_error "MySQL dump failed"
      cat /tmp/mysqldump.err >&2
      rm -f "$dump_file"
      return 1
    fi
  else
    log_info "Backing up all databases"
    if ! mysqldump -h "$DB_HOST" -u "$DB_USER" --all-databases > "$dump_file" 2>/tmp/mysqldump.err; then
      log_error "MySQL dump failed"
      cat /tmp/mysqldump.err >&2
      rm -f "$dump_file"
      return 1
    fi
  fi

  local dump_size
  dump_size=$(stat -f%z "$dump_file" 2>/dev/null || stat -c%s "$dump_file" 2>/dev/null || echo 0)

  if [[ $dump_size -lt 1000 ]]; then
    log_error "Backup too small (likely empty): $dump_size bytes"
    rm -f "$dump_file"
    return 1
  fi

  log_info "Compressing backup... (size: $((dump_size / 1024)) KB)"
  if gzip -f "$dump_file"; then
    log_success "Backup created: $BACKUP_FILE"
    local final_size
    final_size=$(stat -f%z "$BACKUP_FILE" 2>/dev/null || stat -c%s "$BACKUP_FILE" 2>/dev/null)
    log_info "Compressed size: $((final_size / 1024)) KB"
  else
    log_error "Compression failed"
    return 1
  fi
}

# ===== ROTATION =====

rotate_backups() {
  print_section "Rotating old backups (retention: ${RETENTION_DAYS} days)"

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would delete backups older than $RETENTION_DAYS days"
    return 0
  fi

  local cutoff_time
  cutoff_time=$(date -d "$RETENTION_DAYS days ago" +%s 2>/dev/null || \
                 date -v-${RETENTION_DAYS}d +%s 2>/dev/null || \
                 date -j -v-${RETENTION_DAYS}d +%s 2>/dev/null)

  local deleted_count=0
  while IFS= read -r -d '' file; do
    local file_time
    file_time=$(stat -c%Y "$file" 2>/dev/null || stat -f%m "$file" 2>/dev/null)

    if [[ $file_time -lt $cutoff_time ]]; then
      log_info "Deleting old backup: $(basename "$file")"
      rm -f "$file"
      ((deleted_count++))
    fi
  done < <(find "$OUTPUT_DIR" -name "*.gz" -print0)

  if [[ $deleted_count -eq 0 ]]; then
    log_info "No old backups to delete"
  else
    log_success "Deleted $deleted_count old backup(s)"
  fi
}

# ===== MAIN EXECUTION =====

main() {
  print_header "DATABASE BACKUP SCRIPT"
  echo ""

  validate_setup

  case "$BACKUP_TYPE" in
    postgres)
      backup_postgres || exit 1
      ;;
    mysql)
      backup_mysql || exit 1
      ;;
  esac

  rotate_backups

  print_header "BACKUP COMPLETE"
  if [[ $DRY_RUN -eq 0 ]]; then
    log_success "Backup finished successfully"
  fi
}

main
