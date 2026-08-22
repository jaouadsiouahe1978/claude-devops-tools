#!/bin/bash

################################################################################
# Log Rotation Script
# Bascule les fichiers de logs (renommage avec timestamp)
# Usage: ./rotate_logs.sh [dossier_logs]
################################################################################

# Configuration
LOG_DIRS=(
    "/var/log"
    "/var/log/monitoring"
)

BACKUP_DIR="/var/log/backups"
ROTATE_LOG="/var/log/monitoring/rotate.log"

# Créer les dossiers nécessaires
mkdir -p "$BACKUP_DIR" "$(dirname "$ROTATE_LOG")"

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
    echo "[$timestamp] [$level] $message" >> "$ROTATE_LOG"
}

rotate_log_file() {
    local logfile=$1
    local backup_dir=$2

    if [ ! -f "$logfile" ]; then
        return 0
    fi

    # Ne pas archiver les fichiers vides
    if [ ! -s "$logfile" ]; then
        echo -e "${YELLOW}⊘ $logfile: Vide (non archivé)${NC}"
        return 0
    fi

    # Nom du backup avec timestamp
    local filename=$(basename "$logfile")
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${backup_dir}/${filename}.${timestamp}"

    # Copier et tronquer
    if cp "$logfile" "$backup_file"; then
        # Vider le fichier original
        > "$logfile"
        echo -e "${GREEN}✓ $logfile → ${backup_file}${NC}"
        log_message "INFO" "Rotated: $logfile → $backup_file"
        return 0
    else
        echo -e "${RED}✗ Erreur lors de la rotation de $logfile${NC}"
        log_message "ERROR" "Failed to rotate: $logfile"
        return 1
    fi
}

get_size_kb() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0
}

show_backup_stats() {
    echo ""
    echo "STATISTIQUES DES BACKUPS"
    echo "────────────────────────────────────────────────────"
    echo "Dossier des backups: $BACKUP_DIR"
    echo ""

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo "Aucun backup trouvé."
        return
    fi

    echo "Fichiers archivés:"
    ls -lhS "$BACKUP_DIR" | tail -n +2 | awk '{
        printf "  %-35s %10s  %s %s %s\n",
            $9, $5, $6, $7, $8
    }' | tail -20

    local total_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    local file_count=$(find "$BACKUP_DIR" -type f | wc -l)

    echo ""
    echo "Total: $file_count fichiers, $total_size d'espace utilisé"
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  LOG ROTATION - $(date '+%Y-%m-%d %H:%M')     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    local total_files=0
    local rotated_files=0
    local failed_files=0
    local exit_code=0

    # Rotation des logs
    echo "ROTATION EN COURS"
    echo "────────────────────────────────────────────────────"

    for logdir in "${LOG_DIRS[@]}"; do
        if [ ! -d "$logdir" ]; then
            echo -e "${YELLOW}⊘ Dossier non trouvé: $logdir${NC}"
            continue
        fi

        echo ""
        echo "Dossier: $logdir"
        echo ""

        # Trouver les fichiers .log et .log.*
        while IFS= read -r logfile; do
            if [ -f "$logfile" ]; then
                total_files=$((total_files + 1))
                if rotate_log_file "$logfile" "$BACKUP_DIR"; then
                    rotated_files=$((rotated_files + 1))
                else
                    failed_files=$((failed_files + 1))
                    exit_code=1
                fi
            fi
        done < <(find "$logdir" -maxdepth 1 -type f -name "*.log" 2>/dev/null)
    done

    # Afficher les statistiques
    show_backup_stats

    # Résumé
    echo ""
    echo "RÉSUMÉ"
    echo "────────────────────────────────────────────────────"
    echo "Fichiers traités: $rotated_files / $total_files"

    if [ "$failed_files" -gt 0 ]; then
        echo -e "${RED}Erreurs: $failed_files${NC}"
    fi

    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    log_message "INFO" "Log rotation completed: $rotated_files/$total_files"
    exit $exit_code
}

# ============================================================================
# EXÉCUTION
# ============================================================================

# Vérifier si root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Cet script doit être exécuté en tant que root (sudo)${NC}"
    exit 1
fi

main "$@"
