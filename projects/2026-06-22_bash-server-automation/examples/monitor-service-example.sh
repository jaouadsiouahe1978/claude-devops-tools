#!/bin/bash

################################################################################
# Exemple: Monitorer un service (par ex. nginx) avec alertes
# Usage: ./monitor-service-example.sh [service_name] [check_interval]
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"
source "${SCRIPT_DIR}/modules/services.sh"
source "${SCRIPT_DIR}/modules/alerts.sh"

SERVICE_NAME="${1:-nginx}"
CHECK_INTERVAL="${2:-60}"

################################################################################
# Monitorer le service
################################################################################
monitor_service() {
    local service="$SERVICE_NAME"
    local last_status="unknown"
    local down_count=0
    local max_retries=3

    log_info "=== MONITORING DU SERVICE: $service ==="
    log_info "Intervalle de vérification: ${CHECK_INTERVAL}s"
    log_info "Appuyez sur Ctrl+C pour arrêter"
    echo ""

    while true; do
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

        # Vérifier le statut
        if systemctl is-active --quiet "$service"; then
            local status="UP"
            local symbol="✅"
            local color="\033[0;32m"

            # Réinitialiser le compteur
            if [[ "$last_status" == "DOWN" ]]; then
                log_info "✅ Service $service est revenu UP après $down_count tentatives"
                down_count=0
            fi
            last_status="UP"
        else
            local status="DOWN"
            local symbol="❌"
            local color="\033[0;31m"

            ((down_count++))
            last_status="DOWN"

            # Alerter après N essais consécutifs
            if [[ $down_count -ge $max_retries ]]; then
                log_error "$symbol Service $service est DOWN depuis $down_count checks!"
                alert_if_service_down "$service"
            else
                log_warn "$symbol Service $service est DOWN (essai $down_count/$max_retries)"
            fi
        fi

        # Afficher le statut
        echo -e "${color}[$timestamp] $service: $status (uptime: $(systemctl show -p ActiveEnterTimestamp --value $service 2>/dev/null || echo 'N/A'))${NC:-\033[0m}"

        # Pause avant le prochain check
        sleep "$CHECK_INTERVAL"
    done
}

################################################################################
# Afficher l'état détaillé du service
################################################################################
show_detailed_status() {
    log_info "=== STATUS DÉTAILLÉ DU SERVICE: $SERVICE_NAME ==="
    echo ""

    # Statut général
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "🟢 Status: ACTIVE (running)"
    else
        echo "🔴 Status: INACTIVE (dead)"
    fi

    # Activé au boot
    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        echo "⚙️  Boot: ENABLED"
    else
        echo "⚙️  Boot: DISABLED"
    fi

    # Info du service
    echo ""
    show_service_info "$SERVICE_NAME"

    # Logs récents
    echo ""
    log_info "=== LOGS RÉCENTS (dernières 10 lignes) ==="
    show_service_logs "$SERVICE_NAME" 10
}

################################################################################
# Main
################################################################################
main() {
    case "${1:-monitor}" in
        monitor)
            monitor_service
            ;;
        status)
            show_detailed_status
            ;;
        logs)
            local lines="${2:-50}"
            log_info "=== LOGS DU SERVICE: $SERVICE_NAME (dernières $lines lignes) ==="
            show_service_logs "$SERVICE_NAME" "$lines"
            ;;
        restart)
            log_warn "Redémarrage du service: $SERVICE_NAME"
            restart_service "$SERVICE_NAME"
            ;;
        *)
            cat <<EOF
Usage: $0 [command] [options]

Commands:
  monitor [interval]      - Monitore le service en continu
  status                  - Affiche l'état détaillé
  logs [lines]            - Affiche les logs récents
  restart                 - Redémarre le service

Examples:
  $0 monitor 60           # Monitor nginx toutes les 60s
  $0 status               # État détaillé de nginx
  $0 logs 100             # Derniers 100 logs
  $0 restart              # Redémarrer nginx

Service par défaut: nginx
EOF
            return 1
            ;;
    esac
}

# Exécuter
main "$@"
