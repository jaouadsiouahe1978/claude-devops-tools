#!/bin/bash
###############################################################################
# Backup Restore Script
# Restores files from backups with safety checks
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/backup-config.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

###############################################################################
# List Available Backups
###############################################################################

list_backups() {
    log_info "Available backups:"
    echo ""

    local count=0
    while IFS= read -r file; do
        ((count++))
        local size=$(du -h "$file" | cut -f1)
        local mtime=$(date -r "$file" '+%Y-%m-%d %H:%M:%S')
        local basename=$(basename "$file")
        printf "  [%d] %s (%s) %s\n" "$count" "$basename" "$size" "$mtime"
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')

    if [[ $count -eq 0 ]]; then
        log_error "No backups found"
        return 1
    fi
}

###############################################################################
# List Backup Contents
###############################################################################

list_backup_contents() {
    local backup_file="$1"

    if [[ ! -f "$backup_file" ]]; then
        log_error "File not found: $backup_file"
        return 1
    fi

    log_info "Contents of $(basename $backup_file):"
    echo ""

    tar -tzf "$backup_file" | head -50

    local total_files=$(tar -tzf "$backup_file" | wc -l)
    if [[ $total_files -gt 50 ]]; then
        echo ""
        echo "... and $((total_files - 50)) more files"
    fi
}

###############################################################################
# Extract Specific Files
###############################################################################

extract_file() {
    local backup_file="$1"
    local file_pattern="$2"
    local restore_dir="$3"

    if [[ ! -f "$backup_file" ]]; then
        log_error "File not found: $backup_file"
        return 1
    fi

    log_info "Extracting matching files..."
    log_info "  Backup: $(basename $backup_file)"
    log_info "  Pattern: $file_pattern"
    log_info "  Destination: $restore_dir"

    mkdir -p "$restore_dir"

    if tar -xzf "$backup_file" -C "$restore_dir" "$file_pattern" 2>&1 | head -20; then
        log_success "Extraction completed"
        log_info "Files extracted to: $restore_dir"

        # Show extracted files
        echo ""
        log_info "Extracted files:"
        find "$restore_dir" -type f | head -20
    else
        log_error "Extraction failed"
        return 1
    fi
}

###############################################################################
# Full Restore to Directory
###############################################################################

restore_full() {
    local backup_file="$1"
    local restore_dir="$2"

    if [[ ! -f "$backup_file" ]]; then
        log_error "File not found: $backup_file"
        return 1
    fi

    if [[ -d "$restore_dir" ]] && [[ -n "$(ls -A "$restore_dir" 2>/dev/null)" ]]; then
        log_warn "Restore directory is not empty: $restore_dir"
        read -p "Continue? (yes/no): " answer
        if [[ "$answer" != "yes" ]]; then
            log_info "Restore cancelled"
            return 1
        fi
    fi

    log_info "Starting full restore..."
    log_info "  Backup: $(basename $backup_file)"
    log_info "  Destination: $restore_dir"

    mkdir -p "$restore_dir"

    local start_time=$(date +%s)

    if tar -xzf "$backup_file" -C "$restore_dir"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local file_count=$(find "$restore_dir" -type f | wc -l)

        log_success "Full restore completed in ${duration}s"
        log_info "Files restored: ${file_count}"
    else
        log_error "Restore failed"
        return 1
    fi
}

###############################################################################
# Verify Restore
###############################################################################

verify_restore() {
    local restore_dir="$1"

    if [[ ! -d "$restore_dir" ]]; then
        log_error "Restore directory not found: $restore_dir"
        return 1
    fi

    log_info "Verifying restore..."

    local total_files=$(find "$restore_dir" -type f | wc -l)
    local total_dirs=$(find "$restore_dir" -type d | wc -l)
    local total_size=$(du -sh "$restore_dir" | cut -f1)

    log_success "Restore verification complete"
    log_info "  Total files: ${total_files}"
    log_info "  Total directories: ${total_dirs}"
    log_info "  Total size: ${total_size}"
}

###############################################################################
# Interactive Restore
###############################################################################

interactive_restore() {
    log_info "Starting interactive restore..."
    echo ""

    # List backups
    list_backups || return 1

    echo ""
    read -p "Select backup number (or enter full path): " selection

    local backup_file
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        local count=0
        while IFS= read -r file; do
            ((count++))
            if [[ $count -eq $selection ]]; then
                backup_file="$file"
                break
            fi
        done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | awk '{print $2}')
    else
        backup_file="$selection"
    fi

    if [[ ! -f "$backup_file" ]]; then
        log_error "Invalid backup selection"
        return 1
    fi

    echo ""
    log_info "Selected backup: $(basename $backup_file)"

    # List contents
    list_backup_contents "$backup_file"

    echo ""
    echo "Restore options:"
    echo "  1) Extract specific files"
    echo "  2) Full restore"
    echo "  3) Cancel"
    echo ""
    read -p "Select option: " option

    case "$option" in
        1)
            echo ""
            read -p "Enter file pattern (e.g., etc/nginx/): " pattern
            read -p "Enter restore destination: " dest
            extract_file "$backup_file" "$pattern" "$dest"
            ;;
        2)
            echo ""
            read -p "Enter restore destination: " dest
            restore_full "$backup_file" "$dest"
            ;;
        3)
            log_info "Restore cancelled"
            return 0
            ;;
        *)
            log_error "Invalid option"
            return 1
            ;;
    esac
}

###############################################################################
# Usage
###############################################################################

usage() {
    cat << EOF
Usage: $0 <command> [options]

Commands:
  list                  List available backups
  contents <backup>     List backup contents
  extract <backup> <pattern> <dest>
                        Extract specific files
  restore <backup> <dest>
                        Full restore to directory
  interactive           Interactive restore mode
  verify <directory>    Verify restored files

Examples:
  $0 list
  $0 contents /var/backups/custom-backups/backup-2026-07-06.tar.gz
  $0 extract /var/backups/custom-backups/backup-2026-07-06.tar.gz etc/ /restore/etc/
  $0 restore /var/backups/custom-backups/backup-2026-07-06.tar.gz /restore/
  $0 interactive
  $0 verify /restore/
EOF
}

###############################################################################
# Main
###############################################################################

main() {
    local command="${1:-}"

    case "$command" in
        list)
            list_backups
            ;;
        contents)
            if [[ -z "${2:-}" ]]; then
                log_error "Backup file required"
                usage
                exit 1
            fi
            list_backup_contents "$2"
            ;;
        extract)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "Backup, pattern, and destination required"
                usage
                exit 1
            fi
            extract_file "$2" "$3" "$4"
            ;;
        restore)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                log_error "Backup and destination required"
                usage
                exit 1
            fi
            restore_full "$2" "$3"
            ;;
        verify)
            if [[ -z "${2:-}" ]]; then
                log_error "Directory required"
                usage
                exit 1
            fi
            verify_restore "$2"
            ;;
        interactive)
            interactive_restore
            ;;
        *)
            if [[ -z "$command" ]] || [[ "$command" == "help" ]] || [[ "$command" == "-h" ]]; then
                usage
                exit 0
            else
                log_error "Unknown command: $command"
                usage
                exit 1
            fi
            ;;
    esac
}

main "$@"
