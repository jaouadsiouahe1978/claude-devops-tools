#!/bin/bash

################################################################################
# System Module - Informations et monitoring système
################################################################################

################################################################################
# show_system_stats - Affiche les stats système complètes
################################################################################
show_system_stats() {
    log_info "=== INFORMATIONS SYSTÈME ==="

    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Uptime: $(uptime -p)"
    echo "Heure: $(date)"
    echo ""

    show_cpu_info
    echo ""
    show_memory_usage
    echo ""
    show_load_average
}

################################################################################
# show_cpu_info - Affiche les infos CPU
################################################################################
show_cpu_info() {
    log_info "=== CPU ==="

    local cpu_count=$(nproc)
    local cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)

    echo "Nombre de CPUs: $cpu_count"
    echo "Modèle: $cpu_model"
    echo "Fréquence: $(cat /proc/cpuinfo | grep -m1 "cpu MHz" | awk '{print $4}') MHz"
}

################################################################################
# show_load_average - Affiche la charge moyenne
################################################################################
show_load_average() {
    log_info "=== CHARGE SYSTÈME ==="

    local load=$(uptime | awk -F'load average:' '{print $2}')
    local cpu_count=$(nproc)

    echo "Load Average: $load"
    echo "CPUs: $cpu_count"
}

################################################################################
# show_memory_usage - Affiche l'utilisation mémoire
################################################################################
show_memory_usage() {
    log_info "=== MÉMOIRE ==="

    local mem_info=$(free -h | grep Mem)
    local total=$(echo "$mem_info" | awk '{print $2}')
    local used=$(echo "$mem_info" | awk '{print $3}')
    local available=$(echo "$mem_info" | awk '{print $7}')
    local percent=$(echo "scale=1; $(free | grep Mem | awk '{print $3}') * 100 / $(free | grep Mem | awk '{print $2}')" | bc)

    echo "Total:      $total"
    echo "Utilisée:   $used"
    echo "Disponible: $available"
    echo "Pourcentage: ${percent}%"

    # Cache info
    local buffers=$(free -h | grep Mem | awk '{print $6}')
    echo "Cache:      $buffers"
}

################################################################################
# check_memory_usage - Vérifie si la mémoire dépasse le seuil
################################################################################
check_memory_usage() {
    local percent=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    log_info "Utilisation mémoire: ${percent}%"

    if (( percent >= MEMORY_USAGE_THRESHOLD )); then
        log_warn "⚠️  Mémoire critique" "usage=${percent}%"
        return 1
    else
        log_info "✅ Mémoire OK" "usage=${percent}%"
        return 0
    fi
}

################################################################################
# show_processes - Affiche les top N processus
# Usage: show_processes [count] [sort_by]
################################################################################
show_processes() {
    local count="${1:-10}"
    local sort_by="${2:-cpu}"

    log_info "=== TOP $count PROCESSUS (par $sort_by) ==="

    case "$sort_by" in
        cpu)
            ps aux --sort=-%cpu | head -n $((count + 1))
            ;;
        mem)
            ps aux --sort=-%mem | head -n $((count + 1))
            ;;
        *)
            ps aux --sort=-%cpu | head -n $((count + 1))
            ;;
    esac
}

################################################################################
# show_network_interfaces - Liste les interfaces réseau
################################################################################
show_network_interfaces() {
    log_info "=== INTERFACES RÉSEAU ==="

    ip link show | grep -E "^\d+:" | while read line; do
        local interface=$(echo "$line" | cut -d: -f2 | xargs)
        echo "Interface: $interface"
        ip addr show "$interface" 2>/dev/null | grep "inet " | awk '{print "  IP: " $2}'
    done
}

################################################################################
# show_network_stats - Affiche les stats réseau
################################################################################
show_network_stats() {
    log_info "=== STATISTIQUES RÉSEAU ==="

    if command -v netstat &>/dev/null; then
        echo "=== Connexions (résumé) ==="
        netstat -an | tail -1
    elif command -v ss &>/dev/null; then
        echo "=== Connexions (résumé) ==="
        ss -s
    fi
}

################################################################################
# show_listening_ports - Affiche les ports en écoute
################################################################################
show_listening_ports() {
    log_info "=== PORTS EN ÉCOUTE ==="

    if command -v ss &>/dev/null; then
        ss -tlnp 2>/dev/null | tail -n +2
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | tail -n +2
    else
        lsof -i -P -n 2>/dev/null | grep LISTEN
    fi
}

################################################################################
# show_process_by_name - Affiche les processus par nom
# Usage: show_process_by_name "process_name"
################################################################################
show_process_by_name() {
    local process_name="$1"

    if [[ -z "$process_name" ]]; then
        log_error "Usage: show_process_by_name <process_name>"
        return 1
    fi

    log_info "=== PROCESSUS: $process_name ==="
    pgrep -a "$process_name" || echo "Aucun processus trouvé"
}

################################################################################
# get_system_uptime - Affiche le temps d'activité
################################################################################
get_system_uptime() {
    log_info "Uptime du système:"
    uptime
}

################################################################################
# show_system_limits - Affiche les limites système
################################################################################
show_system_limits() {
    log_info "=== LIMITES SYSTÈME ==="
    ulimit -a
}

################################################################################
# get_kernel_messages - Affiche les derniers messages kernel
# Usage: get_kernel_messages [lines]
################################################################################
get_kernel_messages() {
    local lines="${1:-20}"

    log_info "=== $lines DERNIERS MESSAGES KERNEL ==="
    dmesg | tail -n "$lines"
}

################################################################################
# get_sysctl_value - Affiche une valeur sysctl
# Usage: get_sysctl_value "key"
################################################################################
get_sysctl_value() {
    local key="$1"

    if [[ -z "$key" ]]; then
        log_error "Usage: get_sysctl_value <key>"
        return 1
    fi

    sysctl "$key" 2>/dev/null || echo "Clé non trouvée: $key"
}

################################################################################
# show_system_time_sync - Affiche le statut de synchronisation horaire
################################################################################
show_system_time_sync() {
    log_info "=== SYNCHRONISATION HORAIRE ==="

    if command -v timedatectl &>/dev/null; then
        timedatectl
    elif command -v ntpstat &>/dev/null; then
        ntpstat
    else
        echo "Pas d'outil de synchronisation détecté"
    fi
}

################################################################################
# check_system_health - Vérification générale santé système
################################################################################
check_system_health() {
    log_info "=== HEALTH CHECK SYSTÈME ==="

    local issues=0

    # Check load
    local load1=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local cpu_count=$(nproc)
    local load_limit=$(echo "$cpu_count * 1" | bc)

    if (( $(echo "$load1 > $load_limit" | bc -l) )); then
        log_warn "⚠️  Load élevée: $load1"
        ((issues++))
    fi

    # Check memory
    local mem_percent=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    if (( mem_percent >= 90 )); then
        log_warn "⚠️  Mémoire critique: ${mem_percent}%"
        ((issues++))
    fi

    # Check disk
    local disk_percent=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if (( disk_percent >= 90 )); then
        log_warn "⚠️  Disque critique: ${disk_percent}%"
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        log_info "✅ Système en bon état"
        return 0
    else
        log_warn "⚠️  $issues problème(s) détecté(s)"
        return 1
    fi
}

log_debug "Module system chargé"
