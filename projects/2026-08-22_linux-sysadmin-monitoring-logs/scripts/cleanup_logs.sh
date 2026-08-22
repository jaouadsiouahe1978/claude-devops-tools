#!/bin/bash

################################################################################
# Cleanup Logs Script
# Supprime les logs anciens selon la politique de rétention
# Usage: ./cleanup_logs.sh [jours_retention]
################################################################################

# Configuration
BACKUP_DIR="/var/log/backups"
DAYS_RETAIN=${1:-30}
CLEANUP_LOG="/var/log/monitoring/cleanup.log"

# Créer les dossiers nécessaires
mkdir -p "$BACKUP_DIR" "$(dirname "$CLEANUP_LOG")"

# Couleurs
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# FONCTIONS
# ============================================================================

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$CLEANUP_LOG"
}

bytes_to_mb() {
    echo "scale=2; $1 / 1024 / 1024" | bc
}

cleanup_file() {
    local file=$1

    if [ ! -f "$file" ]; then
        return 0
    fi

    local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")

    if rm -f "$file"; then
        echo -e "${GREEN}✓ Supprimé: $(basename "$file") ($(bytes_to_mb "$size") MB)${NC}"
        log_message "INFO" "Deleted: $(basename "$file")"
        echo "$size"
        return 0
    else
        echo -e "${RED}✗ Erreur lors de la suppression: $file${NC}"
        log_message "ERROR" "Failed to delete: $file"
        return 1
    fi
}

get_file_age_days() {
    local file=$1
    local file_timestamp=$(stat -c%Y "$file" 2>/dev/null || stat -f%m "$file")
    local current_timestamp=$(date '+%s')
    local age_seconds=$((current_timestamp - file_timestamp))
    local age_days=$((age_seconds / 86400))

    echo "$age_days"
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  CLEANUP LOGS - $(date '+%Y-%m-%d %H:%M')      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Politique de rétention: $DAYS_RETAIN jours"
    echo ""

    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Dossier non trouvé: $BACKUP_DIR${NC}"
        exit 1
    fi

    # Vérifier si le dossier est vide
    if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo "Aucun fichier à nettoyer."
        log_message "INFO" "No files to cleanup"
        exit 0
    fi

    local total_deleted=0
    local failed=0
    local total_freed=0
    local exit_code=0

    echo "FICHIERS À SUPPRIMER (plus de $DAYS_RETAIN jours)"
    echo "────────────────────────────────────────────────────"

    # Lister tous les fichiers avec leur âge
    echo ""
    printf "%-40s %10s %10s\n" "FICHIER" "ÂGE (jours)" "TAILLE"
    echo "────────────────────────────────────────────────────"

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local age=$(get_file_age_days "$file")
            local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")

            if (( age > DAYS_RETAIN )); then
                printf "%-40s %10d %10s\n" \
                    "$(basename "$file")" "$age" "$(bytes_to_mb "$size") MB"
            fi
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type f | sort)

    echo ""
    echo "SUPPRESSION"
    echo "────────────────────────────────────────────────────"

    # Supprimer les fichiers trop anciens
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local age=$(get_file_age_days "$file")

            if (( age > DAYS_RETAIN )); then
                total_deleted=$((total_deleted + 1))

                freed=$(cleanup_file "$file") || {
                    failed=$((failed + 1))
                    exit_code=1
                    freed=0
                }
                total_freed=$((total_freed + freed))
            fi
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type f -mtime +$DAYS_RETAIN 2>/dev/null)

    # Fichiers conservés
    echo ""
    echo "FICHIERS CONSERVÉS"
    echo "────────────────────────────────────────────────────"

    local kept=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local age=$(get_file_age_days "$file")
            local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")

            if (( age <= DAYS_RETAIN )); then
                printf "  %-36s %6d jours %8s\n" \
                    "$(basename "$file")" "$age" "$(bytes_to_mb "$size") MB"
                kept=$((kept + 1))
            fi
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type f | sort -r | head -10)

    if [ "$kept" -eq 0 ]; then
        echo "  Aucun fichier"
    fi

    # Statistiques
    echo ""
    echo "STATISTIQUES"
    echo "────────────────────────────────────────────────────"
    echo "Fichiers supprimés: $total_deleted"

    if [ "$failed" -gt 0 ]; then
        echo -e "${RED}Erreurs: $failed${NC}"
    fi

    if [ "$total_freed" -gt 0 ]; then
        echo -e "${GREEN}Espace libéré: $(bytes_to_mb "$total_freed") MB${NC}"
    fi

    # Espace total restant
    local total_used=$(du -sh "$BACKUP_DIR" | cut -f1)
    local file_count=$(find "$BACKUP_DIR" -type f | wc -l)
    echo "Espace total utilisé: $total_used ($file_count fichiers)"

    echo ""
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    log_message "INFO" "Cleanup completed: $total_deleted files deleted, $(bytes_to_mb "$total_freed") MB freed"
    exit $exit_code
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
