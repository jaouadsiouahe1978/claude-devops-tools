#!/bin/bash

################################################################################
# System Health Monitoring Script
# Vérifie la santé globale du système (CPU, RAM, Disque, Uptime, Processus)
# Usage: ./system_health.sh
################################################################################

# Configuration
ALERT_THRESHOLD_DISK=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_CPU=80
LOG_FILE="/var/log/monitoring/system_health.log"
ALERT_EMAIL="${ALERT_EMAIL:-admin@localhost}"

# Créer le dossier de logs s'il n'existe pas
mkdir -p "$(dirname "$LOG_FILE")"

# Couleurs pour l'affichage
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

print_header() {
    echo "╔════════════════════════════════════════════════════╗"
    echo "║  SYSTEM HEALTH REPORT - $(date '+%Y-%m-%d %H:%M')        ║"
    echo "╚════════════════════════════════════════════════════╝"
}

print_separator() {
    echo "╟────────────────────────────────────────────────────╢"
}

check_status() {
    local value=$1
    local threshold=$2

    if (( $(echo "$value > $threshold" | bc -l) )); then
        echo "⚠️  CRITIQUE"
    elif (( $(echo "$value > $(($threshold - 20))" | bc -l) )); then
        echo "⚠️  ALERTE"
    else
        echo "✅ OK"
    fi
}

send_alert() {
    local subject=$1
    local message=$2

    log_message "ALERT" "$subject - $message"

    # Envoyer par email si mail est disponible
    if command -v mail &> /dev/null; then
        echo "$message" | mail -s "$subject" "$ALERT_EMAIL" 2>/dev/null
    fi

    # Afficher en rouge
    echo -e "${RED}ALERTE: $subject${NC}"
}

# ============================================================================
# MONITORING CPU
# ============================================================================

get_cpu_load() {
    local load1=$(echo "scale=2; $(cut -d' ' -f1 /proc/loadavg) * 100 / $(nproc)" | bc)
    local load5=$(echo "scale=2; $(cut -d' ' -f2 /proc/loadavg) * 100 / $(nproc)" | bc)
    local load15=$(echo "scale=2; $(cut -d' ' -f3 /proc/loadavg) * 100 / $(nproc)" | bc)

    printf "%.0f" "$load1"
}

# ============================================================================
# MONITORING MÉMOIRE
# ============================================================================

get_memory_usage() {
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local mem_used=$((mem_total - mem_available))
    local mem_percent=$((mem_used * 100 / mem_total))

    echo "$mem_percent"
}

get_memory_details() {
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local mem_used=$((mem_total - mem_available))
    local mem_total_gb=$(echo "scale=1; $mem_total / 1024 / 1024" | bc)
    local mem_used_gb=$(echo "scale=1; $mem_used / 1024 / 1024" | bc)

    echo "$mem_used_gb / $mem_total_gb GB"
}

# ============================================================================
# MONITORING DISQUE
# ============================================================================

get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

get_disk_details() {
    df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'
}

# ============================================================================
# MONITORING SYSTÈME
# ============================================================================

get_uptime() {
    uptime -p 2>/dev/null || uptime | awk -F'up' '{print $2}' | awk '{$NF=""; print}'
}

get_process_count() {
    ps aux | wc -l
}

get_cpu_count() {
    nproc
}

get_hostname() {
    hostname
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    print_header
    echo ""

    # Informations système
    echo "║ 🖥️  SYSTÈME                                          ║"
    printf "║ Hostname: %-43s ║\n" "$(get_hostname)"
    printf "║ Uptime: %-45s ║\n" "$(get_uptime)"
    printf "║ CPU Cores: %-42s ║\n" "$(get_cpu_count)"

    print_separator

    # CPU Load
    echo "║ 📈 CPU LOAD                                          ║"
    local cpu_load=$(get_cpu_load)
    local cpu_status=$(check_status "$cpu_load" "$ALERT_THRESHOLD_CPU")
    printf "║ Current Load: %3d%% - %s           ║\n" "$cpu_load" "$cpu_status"

    if (( cpu_load > ALERT_THRESHOLD_CPU )); then
        send_alert "CPU CRITIQUE" "CPU load: $cpu_load%"
    fi

    print_separator

    # Mémoire
    echo "║ 💾 MÉMOIRE                                           ║"
    local mem_usage=$(get_memory_usage)
    local mem_status=$(check_status "$mem_usage" "$ALERT_THRESHOLD_MEMORY")
    printf "║ Usage: %3d%% - %s (%s)    ║\n" "$mem_usage" "$mem_status" "$(get_memory_details)"

    if (( mem_usage > ALERT_THRESHOLD_MEMORY )); then
        send_alert "MÉMOIRE CRITIQUE" "Memory usage: $mem_usage%"
    fi

    print_separator

    # Disque
    echo "║ 💿 DISQUE                                            ║"
    local disk_usage=$(get_disk_usage)
    local disk_status=$(check_status "$disk_usage" "$ALERT_THRESHOLD_DISK")
    printf "║ / Usage: %3d%% - %s (%s)       ║\n" "$disk_usage" "$disk_status" "$(get_disk_details)"

    if (( disk_usage > ALERT_THRESHOLD_DISK )); then
        send_alert "DISQUE CRITIQUE" "Disk usage /: $disk_usage%"
    fi

    print_separator

    # Processus
    echo "║ ⚙️  PROCESSUS                                          ║"
    printf "║ Running Processes: %-36s ║\n" "$(get_process_count)"

    echo "╚════════════════════════════════════════════════════╝"
    echo ""

    # Logging
    log_message "INFO" "Health check completed - CPU:$cpu_load% MEM:$mem_usage% DISK:$disk_usage%"
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
