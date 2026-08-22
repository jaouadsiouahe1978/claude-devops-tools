#!/bin/bash

################################################################################
# Compress Old Logs Script
# Compresse les fichiers de logs anciens pour économiser l'espace disque
# Usage: ./compress_old_logs.sh [jours]
################################################################################

# Configuration
BACKUP_DIR="/var/log/backups"
DAYS_OLD=${1:-7}
COMPRESS_LOG="/var/log/monitoring/compress.log"

# Créer les dossiers nécessaires
mkdir -p "$BACKUP_DIR" "$(dirname "$COMPRESS_LOG")"

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
    echo "[$timestamp] [$level] $message" >> "$COMPRESS_LOG"
}

bytes_to_mb() {
    echo "scale=2; $1 / 1024 / 1024" | bc
}

compress_file() {
    local logfile=$1

    if [ ! -f "$logfile" ]; then
        return 0
    fi

    # Ne pas compresser les fichiers déjà compressés
    if [[ "$logfile" =~ \.(gz|bz2|xz|zip)$ ]]; then
        return 0
    fi

    # Fichier déjà compressé?
    if [ -f "${logfile}.gz" ]; then
        return 0
    fi

    local size_before=$(stat -c%s "$logfile" 2>/dev/null || stat -f%z "$logfile")

    if gzip -9 "$logfile" 2>/dev/null; then
        local size_after=$(stat -c%s "${logfile}.gz" 2>/dev/null || stat -f%z "${logfile}.gz")
        local ratio=$((100 - (size_after * 100 / size_before)))

        echo -e "${GREEN}✓ $logfile${NC}"
        echo "  Avant: $(bytes_to_mb "$size_before") MB"
        echo "  Après: $(bytes_to_mb "$size_after") MB (compression: $ratio%)"

        log_message "INFO" "Compressed: $(basename "$logfile") (${ratio}% reduction)"
        return 0
    else
        echo -e "${RED}✗ Erreur lors de la compression: $logfile${NC}"
        log_message "ERROR" "Failed to compress: $logfile"
        return 1
    fi
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  COMPRESS LOGS - $(date '+%Y-%m-%d %H:%M')      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Compression des fichiers de plus de $DAYS_OLD jours"
    echo ""

    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Dossier non trouvé: $BACKUP_DIR${NC}"
        exit 1
    fi

    local total_compressed=0
    local failed=0
    local exit_code=0
    local space_saved=0

    echo "FICHIERS À COMPRESSER"
    echo "────────────────────────────────────────────────────"

    # Chercher les fichiers non compressés de plus de N jours
    while IFS= read -r logfile; do
        if [ -f "$logfile" ]; then
            total_compressed=$((total_compressed + 1))

            local size_before=$(stat -c%s "$logfile" 2>/dev/null || stat -f%z "$logfile")

            if compress_file "$logfile"; then
                local size_after=$(stat -c%s "${logfile}.gz" 2>/dev/null || stat -f%z "${logfile}.gz")
                space_saved=$((space_saved + size_before - size_after))
            else
                failed=$((failed + 1))
                exit_code=1
            fi
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type f ! -name "*.gz" ! -name "*.bz2" ! -name "*.xz" -mtime +$DAYS_OLD 2>/dev/null)

    # Afficher les fichiers déjà compressés
    echo ""
    echo "FICHIERS DÉJÀ COMPRESSÉS"
    echo "────────────────────────────────────────────────────"
    ls -lhS "$BACKUP_DIR"/*.gz 2>/dev/null | awk '{
        printf "  %-35s %10s\n", $9, $5
    }' | head -10 || echo "  Aucun fichier compressé trouvé."

    # Statistiques d'espace disque
    echo ""
    echo "STATISTIQUES"
    echo "────────────────────────────────────────────────────"
    echo "Fichiers compressés: $total_compressed"

    if [ "$failed" -gt 0 ]; then
        echo -e "${RED}Erreurs: $failed${NC}"
    fi

    if [ "$space_saved" -gt 0 ]; then
        echo -e "${GREEN}Espace économisé: $(bytes_to_mb "$space_saved") MB${NC}"
    fi

    # Espace total utilisé
    local total_used=$(du -sh "$BACKUP_DIR" | cut -f1)
    echo "Espace total utilisé: $total_used"

    echo ""
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    log_message "INFO" "Compression completed: $total_compressed files"
    exit $exit_code
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
