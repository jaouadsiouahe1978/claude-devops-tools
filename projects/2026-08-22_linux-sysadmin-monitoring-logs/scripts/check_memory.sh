#!/bin/bash

################################################################################
# Memory Usage Checker Script
# Vérifie l'utilisation de la RAM et SWAP
# Usage: ./check_memory.sh [seuil_pourcentage]
################################################################################

# Configuration
ALERT_THRESHOLD=${1:-85}
LOG_FILE="/var/log/monitoring/memory_check.log"
ALERT_EMAIL="${ALERT_EMAIL:-admin@localhost}"

# Créer le dossier de logs
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

bytes_to_gb() {
    echo "scale=2; $1 / 1024 / 1024" | bc
}

bytes_to_mb() {
    echo "scale=1; $1 / 1024" | bc
}

get_memory_stats() {
    # Lire /proc/meminfo
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local mem_buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
    local mem_cached=$(grep "^Cached:" /proc/meminfo | awk '{print $2}')
    local mem_used=$((mem_total - mem_available))

    # Calculer les pourcentages
    local mem_used_percent=$((mem_used * 100 / mem_total))
    local mem_available_percent=$((mem_available * 100 / mem_total))

    # Afficher les résultats
    echo "Total Memory:        $(bytes_to_gb "$mem_total") GB"
    echo "Used Memory:         $(bytes_to_gb "$mem_used") GB ($mem_used_percent%)"
    echo "Available Memory:    $(bytes_to_gb "$mem_available") GB ($mem_available_percent%)"
    echo "Free Memory:         $(bytes_to_gb "$mem_free") GB"
    echo "Buffers:             $(bytes_to_mb "$mem_buffers") MB"
    echo "Cached:              $(bytes_to_mb "$mem_cached") MB"

    # Alerte si dépassement du seuil
    if (( mem_used_percent > ALERT_THRESHOLD )); then
        send_alert "MÉMOIRE CRITIQUE" \
            "Utilisation RAM: $mem_used_percent% ($(bytes_to_gb "$mem_used") GB / $(bytes_to_gb "$mem_total") GB)"
        return 1
    elif (( mem_used_percent > (ALERT_THRESHOLD - 15) )); then
        echo -e "${YELLOW}⚠️  Attention: Mémoire proche du seuil critique${NC}"
        log_message "WARN" "Memory usage: $mem_used_percent%"
        return 0
    else
        log_message "INFO" "Memory usage: $mem_used_percent% - OK"
        return 0
    fi
}

get_swap_stats() {
    # Lire les infos SWAP
    local swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    local swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    local swap_used=$((swap_total - swap_free))

    if [ "$swap_total" -eq 0 ]; then
        echo "SWAP:                Désactivé"
        return 0
    fi

    local swap_used_percent=$((swap_used * 100 / swap_total))

    echo "SWAP Total:          $(bytes_to_gb "$swap_total") GB"
    echo "SWAP Used:           $(bytes_to_gb "$swap_used") GB ($swap_used_percent%)"
    echo "SWAP Free:           $(bytes_to_gb "$swap_free") GB"

    if (( swap_used_percent > 50 )); then
        echo -e "${YELLOW}⚠️  Attention: SWAP en utilisation importante${NC}"
        log_message "WARN" "SWAP usage: $swap_used_percent%"
        return 0
    fi
}

get_top_processes() {
    echo ""
    echo "Top 5 Processus (par utilisation mémoire):"
    echo "────────────────────────────────────────────"
    ps aux --sort=-%mem | head -n 6 | tail -n 5 | awk '{
        printf "%-10s %3d%% %6.1f MB %s\n",
            $1, int($4), $6/1024, substr($0, index($0,$11))
    }'
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  MEMORY USAGE CHECK - $(date '+%Y-%m-%d %H:%M')  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Seuil d'alerte: $ALERT_THRESHOLD%"
    echo ""

    echo "MÉMOIRE PHYSIQUE"
    echo "────────────────────────────────────────────"
    get_memory_stats
    local exit_code=$?

    echo ""
    echo "SWAP"
    echo "────────────────────────────────────────────"
    get_swap_stats

    # Top processus
    get_top_processes

    echo ""
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    log_message "INFO" "Memory check completed"
    exit $exit_code
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
