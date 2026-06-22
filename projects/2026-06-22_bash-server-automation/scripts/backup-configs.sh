#!/bin/bash

################################################################################
# Backup Configs - Sauvegarde les fichiers de configuration critiques
# Usage: ./backup-configs.sh [output_dir]
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"

OUTPUT_DIR="${1:-${SCRIPT_DIR}/backups}"
BACKUP_NAME="config-backup-$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${OUTPUT_DIR}/${BACKUP_NAME}.tar.gz"

mkdir -p "$OUTPUT_DIR"

# Liste des répertoires/fichiers à sauvegarder
BACKUP_PATHS=(
    "/etc/ssh"
    "/etc/sudoers"
    "/etc/passwd"
    "/etc/group"
    "/etc/hosts"
    "/etc/resolv.conf"
    "/etc/fstab"
    "/etc/crontab"
    "/root/.ssh"
    "/var/spool/cron"
)

################################################################################
# Fonction de backup
################################################################################
backup_configs() {
    log_info "=== SAUVEGARDE DES CONFIGURATIONS ==="
    log_info "Destination: $BACKUP_FILE"

    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    local backed_up=0
    local failed=0

    for path in "${BACKUP_PATHS[@]}"; do
        if [[ -e "$path" ]]; then
            log_debug "Sauvegarde de: $path"
            if sudo cp -r "$path" "$temp_dir/" 2>/dev/null; then
                ((backed_up++))
            else
                log_warn "Impossible de copier: $path"
                ((failed++))
            fi
        else
            log_debug "Chemin non trouvé: $path"
        fi
    done

    # Créer l'archive
    log_info "Création de l'archive tar.gz..."
    if sudo tar -czf "$BACKUP_FILE" -C "$temp_dir" . 2>/dev/null; then
        local size=$(du -h "$BACKUP_FILE" | cut -f1)
        log_info "Sauvegarde effectuée avec succès" "size=$size backed_up=$backed_up failed=$failed"
    else
        log_error "Impossible de créer l'archive"
        return 1
    fi
}

################################################################################
# Fonction de listing
################################################################################
list_backups() {
    log_info "=== SAUVEGARDES DISPONIBLES ==="
    ls -lh "$OUTPUT_DIR" | tail -n +2 | awk '{printf "  %-30s %10s  %s %s %s\n", $9, $5, $6, $7, $8}'
}

################################################################################
# Fonction de cleanup
################################################################################
cleanup_old_backups() {
    local days="${1:-30}"

    log_warn "Suppression des sauvegardes plus vieilles que $days jours..."

    local deleted=0
    for file in "$OUTPUT_DIR"/*.tar.gz; do
        if [[ -f "$file" ]]; then
            local age=$(( ($(date +%s) - $(stat -c %Y "$file")) / 86400 ))
            if [[ $age -gt $days ]]; then
                log_debug "Suppression: $(basename $file)"
                rm -f "$file"
                ((deleted++))
            fi
        fi
    done

    log_info "Nettoyage effectué" "deleted=$deleted days_threshold=$days"
}

################################################################################
# Fonction de restauration
################################################################################
restore_from_backup() {
    local backup_file="$1"

    if [[ ! -f "$backup_file" ]]; then
        log_error "Fichier de backup non trouvé: $backup_file"
        return 1
    fi

    log_warn "RESTAURATION depuis: $(basename $backup_file)"
    log_warn "Cette opération va écraser les fichiers de configuration!"

    # Demander confirmation
    read -p "Êtes-vous sûr? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Restauration annulée"
        return 0
    fi

    log_warn "Restauration en cours..."
    if sudo tar -xzf "$backup_file" -C / 2>/dev/null; then
        log_info "Restauration effectuée avec succès"
    else
        log_error "Impossible de restaurer depuis le backup"
        return 1
    fi
}

################################################################################
# Main
################################################################################
main() {
    case "${1:-backup}" in
        backup)
            backup_configs
            ;;
        list)
            list_backups
            ;;
        cleanup)
            cleanup_old_backups "${2:-30}"
            ;;
        restore)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 restore <backup_file>"
                return 1
            fi
            restore_from_backup "$2"
            ;;
        *)
            cat <<EOF
Usage: $0 <command> [options]

Commands:
  backup              - Crée une sauvegarde des configurations
  list                - Liste toutes les sauvegardes
  cleanup [days]      - Supprime les sauvegardes plus vieilles que N jours (défaut: 30)
  restore <file>      - Restaure une sauvegarde

Examples:
  $0 backup                              # Crée une sauvegarde
  $0 list                                # Liste les sauvegardes
  $0 cleanup 60                          # Supprime les backups > 60j
  $0 restore backups/config-backup-*.tar.gz  # Restaure un backup

EOF
            return 1
            ;;
    esac
}

main "$@"
