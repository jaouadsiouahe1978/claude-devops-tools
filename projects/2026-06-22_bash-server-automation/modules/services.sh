#!/bin/bash

################################################################################
# Services Module - Gestion des services systemd
################################################################################

################################################################################
# list_services - Liste tous les services
################################################################################
list_services() {
    log_info "=== SERVICES SYSTEMD ==="
    systemctl list-units --type=service --state=running --no-pager | grep -v "^--" | tail -n +2
}

################################################################################
# get_service_status - Affiche le statut d'un service
# Usage: get_service_status "service_name"
################################################################################
get_service_status() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: get_service_status <service_name>"
        return 1
    fi

    if systemctl is-active --quiet "$service"; then
        log_info "Service $service est ACTIF"
        return 0
    else
        log_warn "Service $service est INACTIF"
        return 1
    fi
}

################################################################################
# start_service - Démarre un service
# Usage: start_service "service_name"
################################################################################
start_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: start_service <service_name>"
        return 1
    fi

    log_info "Démarrage du service: $service"

    if sudo systemctl start "$service"; then
        log_info "Service démarré avec succès" "service=$service"
        return 0
    else
        log_error "Impossible de démarrer le service" "service=$service"
        return 1
    fi
}

################################################################################
# stop_service - Arrête un service
# Usage: stop_service "service_name"
################################################################################
stop_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: stop_service <service_name>"
        return 1
    fi

    log_info "Arrêt du service: $service"

    if sudo systemctl stop "$service"; then
        log_info "Service arrêté avec succès" "service=$service"
        return 0
    else
        log_error "Impossible d'arrêter le service" "service=$service"
        return 1
    fi
}

################################################################################
# restart_service - Redémarre un service
# Usage: restart_service "service_name"
################################################################################
restart_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: restart_service <service_name>"
        return 1
    fi

    log_info "Redémarrage du service: $service"

    if sudo systemctl restart "$service"; then
        log_info "Service redémarré avec succès" "service=$service"
        return 0
    else
        log_error "Impossible de redémarrer le service" "service=$service"
        return 1
    fi
}

################################################################################
# reload_service - Recharge la configuration d'un service
# Usage: reload_service "service_name"
################################################################################
reload_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: reload_service <service_name>"
        return 1
    fi

    log_info "Rechargement de la configuration: $service"

    if sudo systemctl reload "$service"; then
        log_info "Configuration rechargée avec succès" "service=$service"
        return 0
    else
        log_error "Impossible de recharger la configuration" "service=$service"
        return 1
    fi
}

################################################################################
# enable_service - Active un service au boot
# Usage: enable_service "service_name"
################################################################################
enable_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: enable_service <service_name>"
        return 1
    fi

    log_info "Activation au boot: $service"

    if sudo systemctl enable "$service"; then
        log_info "Service activé au boot" "service=$service"
        return 0
    else
        log_error "Impossible d'activer le service au boot" "service=$service"
        return 1
    fi
}

################################################################################
# disable_service - Désactive un service au boot
# Usage: disable_service "service_name"
################################################################################
disable_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: disable_service <service_name>"
        return 1
    fi

    # Vérifier que c'est pas un service critique
    for critical in "${CRITICAL_SERVICES[@]}"; do
        if [[ "$service" == "$critical" ]]; then
            log_error "Impossible de désactiver le service critique: $service"
            return 1
        fi
    done

    log_warn "Désactivation au boot: $service"

    if sudo systemctl disable "$service"; then
        log_info "Service désactivé au boot" "service=$service"
        return 0
    else
        log_error "Impossible de désactiver le service au boot" "service=$service"
        return 1
    fi
}

################################################################################
# is_service_enabled - Vérifie si un service est activé au boot
# Usage: is_service_enabled "service_name"
################################################################################
is_service_enabled() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: is_service_enabled <service_name>"
        return 1
    fi

    if systemctl is-enabled --quiet "$service"; then
        return 0
    else
        return 1
    fi
}

################################################################################
# show_service_logs - Affiche les logs d'un service
# Usage: show_service_logs "service_name" [lines]
################################################################################
show_service_logs() {
    local service="$1"
    local lines="${2:-20}"

    if [[ -z "$service" ]]; then
        log_error "Usage: show_service_logs <service_name> [lines]"
        return 1
    fi

    log_info "=== LOGS du service: $service (dernières $lines lignes) ==="
    journalctl -u "$service" -n "$lines" --no-pager
}

################################################################################
# show_service_info - Affiche les détails d'un service
# Usage: show_service_info "service_name"
################################################################################
show_service_info() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: show_service_info <service_name>"
        return 1
    fi

    log_info "=== INFO du service: $service ==="
    systemctl show "$service" --all
}

################################################################################
# restart_if_crashed - Redémarre un service s'il est inactif
# Usage: restart_if_crashed "service_name"
################################################################################
restart_if_crashed() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: restart_if_crashed <service_name>"
        return 1
    fi

    if ! systemctl is-active --quiet "$service"; then
        log_warn "Service crash détecté: $service"
        restart_service "$service"
    fi
}

log_debug "Module services chargé"
