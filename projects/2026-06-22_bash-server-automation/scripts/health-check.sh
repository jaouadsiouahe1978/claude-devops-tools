#!/bin/bash

################################################################################
# Health Check - Vérification complète santé du serveur
# Peut être appelé par cron quotidiennement
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"
source "${SCRIPT_DIR}/modules/system.sh"
source "${SCRIPT_DIR}/modules/disk.sh"
source "${SCRIPT_DIR}/modules/services.sh"
source "${SCRIPT_DIR}/modules/alerts.sh"

trap 'log_error "Health check failed"' EXIT

################################################################################
# Main health check
################################################################################
main() {
    log_info "╔════════════════════════════════════════════════════════╗"
    log_info "║         HEALTH CHECK COMPLET DU SERVEUR                ║"
    log_info "║         $(date '+%Y-%m-%d %H:%M:%S')                               ║"
    log_info "╚════════════════════════════════════════════════════════╝"

    local issues=0

    # 1. Check CPU load
    log_info "🔍 [1/6] Vérification CPU Load..."
    local load1=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local cpu_count=$(nproc)
    local load_limit=$(echo "$cpu_count * 0.8" | bc)

    if (( $(echo "$load1 > $load_limit" | bc -l) )); then
        log_error "❌ CPU Load critique" "load=$load1 limit=$load_limit"
        alert_if_high_load
        ((issues++))
    else
        log_info "✅ CPU Load OK" "load=$load1"
    fi
    echo ""

    # 2. Check Memory
    log_info "🔍 [2/6] Vérification Mémoire..."
    if ! check_memory_usage; then
        alert_if_memory_critical
        ((issues++))
    fi
    echo ""

    # 3. Check Disk
    log_info "🔍 [3/6] Vérification Disque..."
    if ! check_disk_usage; then
        alert_if_disk_critical
        ((issues++))
    fi
    echo ""

    # 4. Check Services
    log_info "🔍 [4/6] Vérification Services Critiques..."
    local critical_services=("sshd" "systemd-logind")
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_info "✅ Service $service actif"
        else
            log_error "❌ Service $service INACTIF"
            alert_if_service_down "$service"
            ((issues++))
        fi
    done
    echo ""

    # 5. Check Network
    log_info "🔍 [5/6] Vérification Réseau..."
    if ping -c 1 8.8.8.8 &>/dev/null; then
        log_info "✅ Connectivité réseau OK"
    else
        log_warn "⚠️  Pas de connectivité réseau (8.8.8.8)"
    fi
    echo ""

    # 6. Check Disk Space Trend
    log_info "🔍 [6/6] Tendance occupation disque..."
    show_disk_usage
    echo ""

    # Summary
    echo ""
    log_info "╔════════════════════════════════════════════════════════╗"
    if [[ $issues -eq 0 ]]; then
        log_info "║          ✅ TOUS LES CHECKS PASSÉS AVEC SUCCÈS          ║"
    else
        log_error "║          ❌ $issues PROBLÈME(S) DÉTECTÉ(S)                    ║"
    fi
    log_info "║          Rapport généré: $(date '+%Y-%m-%d %H:%M:%S')             ║"
    log_info "╚════════════════════════════════════════════════════════╝"

    return $issues
}

main "$@"
