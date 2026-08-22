#!/bin/bash

################################################################################
# Disk Space Checker Script
# Vérifie l'utilisation du disque et alerte si dépassement du seuil
# Usage: ./check_disk.sh [seuil_pourcentage]
################################################################################

# Configuration
ALERT_THRESHOLD=${1:-80}
LOG_FILE="/var/log/monitoring/disk_check.log"
ALERT_EMAIL="${ALERT_EMAIL:-admin@localhost}"

# Créer le dossier de logs s'il n'existe pas
mkdir -p "$(dirname "$LOG_FILE")"

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
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

send_alert() {
    local subject=$1
    local message=$2

    log_message "ALERT" "$subject - $message"

    if command -v mail &> /dev/null; then
        echo "$message" | mail -s "$subject" "$ALERT_EMAIL" 2>/dev/null
    fi

    echo -e "${RED}⚠️  ALERTE: $subject${NC}"
}

check_disk_usage() {
    local partition=$1
    local threshold=$2

    # Utilisation actuelle
    local usage=$(df "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')
    local used=$(df -h "$partition" | awk 'NR==2 {print $3}')
    local total=$(df -h "$partition" | awk 'NR==2 {print $2}')
    local available=$(df -h "$partition" | awk 'NR==2 {print $4}')

    # Déterminer le statut
    if (( usage > threshold )); then
        send_alert "Disque CRITIQUE sur $partition" \
            "Utilisation: $usage% ($used/$total) - Disponible: $available"
        echo -e "${RED}✗ $partition: $usage% ($used/$total) - Disponible: $available${NC}"
        return 1
    elif (( usage > (threshold - 20) )); then
        echo -e "${YELLOW}⚠️  $partition: $usage% ($used/$total) - Disponible: $available${NC}"
        log_message "WARN" "$partition: $usage% - Approchant le seuil critique"
        return 0
    else
        echo -e "${GREEN}✓ $partition: $usage% ($used/$total) - Disponible: $available${NC}"
        log_message "INFO" "$partition: $usage% - OK"
        return 0
    fi
}

check_inode_usage() {
    local partition=$1

    local inode_usage=$(df -i "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')

    if (( inode_usage > 85 )); then
        send_alert "Inodes CRITIQUE sur $partition" \
            "Utilisation inodes: $inode_usage%"
        echo -e "${RED}✗ Inodes $partition: $inode_usage%${NC}"
        return 1
    elif (( inode_usage > 70 )); then
        echo -e "${YELLOW}⚠️  Inodes $partition: $inode_usage%${NC}"
        return 0
    else
        echo -e "${GREEN}✓ Inodes $partition: $inode_usage%${NC}"
        return 0
    fi
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  DISK USAGE CHECK - $(date '+%Y-%m-%d %H:%M')  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Seuil d'alerte: $ALERT_THRESHOLD%"
    echo ""

    # Afficher l'en-tête du tableau
    echo "PARTITION                 USAGE    USED        TOTAL       AVAILABLE"
    echo "─────────────────────────────────────────────────────────────────────"

    local exit_code=0
    local partitions=()

    # Déterminer les partitions à vérifier
    while IFS= read -r line; do
        local partition=$(echo "$line" | awk '{print $6}')
        partitions+=("$partition")
    done < <(df -h | tail -n +2)

    # Vérifier chaque partition
    for partition in "${partitions[@]}"; do
        check_disk_usage "$partition" "$ALERT_THRESHOLD" || exit_code=1
    done

    echo ""
    echo -e "${BLUE}INODE USAGE${NC}"
    echo "─────────────────────────────────────────────────────────────────────"

    for partition in "${partitions[@]}"; do
        check_inode_usage "$partition" || exit_code=1
    done

    echo ""
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    log_message "INFO" "Disk check completed with exit code: $exit_code"
    exit $exit_code
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
