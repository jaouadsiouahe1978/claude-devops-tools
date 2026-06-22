#!/bin/bash

################################################################################
# Server Manager - Framework d'automation de serveurs Linux
# Gère les utilisateurs, paquets, services, et monitoring
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sourcer la configuration et les modules
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"
source "${SCRIPT_DIR}/modules/users.sh"
source "${SCRIPT_DIR}/modules/packages.sh"
source "${SCRIPT_DIR}/modules/services.sh"
source "${SCRIPT_DIR}/modules/disk.sh"
source "${SCRIPT_DIR}/modules/system.sh"

# Cleanup en cas d'erreur
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Server Manager crashed" "exit_code=$exit_code"
    fi
}
trap cleanup EXIT

################################################################################
# Affiche l'aide
################################################################################
show_usage() {
    cat <<EOF
Usage: $0 <COMMAND> [OPTIONS]

COMMANDS:
  status                    - Affiche l'état complet du serveur
  create-user <user>        - Crée un nouvel utilisateur
  delete-user <user>        - Supprime un utilisateur
  install <packages...>     - Installe des paquets
  remove <packages...>      - Supprime des paquets
  list-services             - Liste tous les services
  enable-service <name>     - Active un service au boot
  disable-service <name>    - Désactive un service au boot
  restart-service <name>    - Redémarre un service
  check-disk                - Vérifie l'utilisation disque
  health-check              - Vérification complète santé serveur
  version                   - Affiche la version

OPTIONS:
  -h, --help                - Affiche cette aide
  -v, --verbose             - Mode verbeux (DEBUG=1)

EXAMPLES:
  $0 status
  $0 create-user devops
  $0 install vim curl git
  $0 health-check
EOF
}

################################################################################
# Commande: Status
################################################################################
cmd_status() {
    log_info "=== STATUS DU SERVEUR ==="
    show_system_stats
    show_disk_usage
    show_memory_usage
    show_cpu_info
}

################################################################################
# Commande: Create User
################################################################################
cmd_create_user() {
    local username="$1"
    if [[ -z "$username" ]]; then
        log_error "Usage: $0 create-user <username>"
        return 1
    fi

    log_info "Création de l'utilisateur: $username"
    create_user "$username"
    log_info "Utilisateur créé avec succès"
}

################################################################################
# Commande: Delete User
################################################################################
cmd_delete_user() {
    local username="$1"
    if [[ -z "$username" ]]; then
        log_error "Usage: $0 delete-user <username>"
        return 1
    fi

    log_warn "Suppression de l'utilisateur: $username"
    delete_user "$username"
    log_info "Utilisateur supprimé"
}

################################################################################
# Commande: Install Packages
################################################################################
cmd_install() {
    if [[ $# -eq 0 ]]; then
        log_error "Usage: $0 install <package1> [package2] ..."
        return 1
    fi

    local packages=("$@")
    log_info "Installation de ${#packages[@]} paquet(s): ${packages[*]}"
    install_packages "${packages[@]}"
    log_info "Installation terminée"
}

################################################################################
# Commande: Remove Packages
################################################################################
cmd_remove() {
    if [[ $# -eq 0 ]]; then
        log_error "Usage: $0 remove <package1> [package2] ..."
        return 1
    fi

    local packages=("$@")
    log_warn "Suppression de ${#packages[@]} paquet(s): ${packages[*]}"
    remove_packages "${packages[@]}"
    log_info "Suppression terminée"
}

################################################################################
# Commande: List Services
################################################################################
cmd_list_services() {
    log_info "=== SERVICES SYSTEMD ==="
    list_services
}

################################################################################
# Commande: Enable Service
################################################################################
cmd_enable_service() {
    local service="$1"
    if [[ -z "$service" ]]; then
        log_error "Usage: $0 enable-service <service-name>"
        return 1
    fi

    log_info "Activation du service au boot: $service"
    enable_service "$service"
    log_info "Service activé"
}

################################################################################
# Commande: Disable Service
################################################################################
cmd_disable_service() {
    local service="$1"
    if [[ -z "$service" ]]; then
        log_error "Usage: $0 disable-service <service-name>"
        return 1
    fi

    log_warn "Désactivation du service au boot: $service"
    disable_service "$service"
    log_info "Service désactivé"
}

################################################################################
# Commande: Restart Service
################################################################################
cmd_restart_service() {
    local service="$1"
    if [[ -z "$service" ]]; then
        log_error "Usage: $0 restart-service <service-name>"
        return 1
    fi

    log_info "Redémarrage du service: $service"
    restart_service "$service"
    log_info "Service redémarré"
}

################################################################################
# Commande: Check Disk
################################################################################
cmd_check_disk() {
    log_info "=== VÉRIFICATION DISQUES ==="
    check_disk_usage
}

################################################################################
# Commande: Health Check
################################################################################
cmd_health_check() {
    log_info "=== HEALTH CHECK COMPLET ==="

    local errors=0

    # Check CPU
    if ! check_cpu_load; then
        ((errors++))
    fi

    # Check Memory
    if ! check_memory_usage; then
        ((errors++))
    fi

    # Check Disk
    if ! check_disk_usage; then
        ((errors++))
    fi

    # Check Connectivity
    if ! check_network; then
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        log_info "✅ Tous les checks sont OK"
        return 0
    else
        log_error "❌ $errors problème(s) détecté(s)"
        return 1
    fi
}

################################################################################
# Fonction helper: Check CPU
################################################################################
check_cpu_load() {
    local load1=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local cpu_count=$(nproc)
    local load_limit=$(echo "$cpu_count * 0.8" | bc)

    log_info "CPU Load: $load1 (limite: $load_limit)"

    if (( $(echo "$load1 > $load_limit" | bc -l) )); then
        log_warn "⚠️  CPU load élevée"
        return 1
    fi
    return 0
}

################################################################################
# Fonction helper: Check Memory
################################################################################
check_memory_usage() {
    local mem_info=$(free -h | grep Mem)
    local mem_used=$(echo "$mem_info" | awk '{print $3}')
    local mem_total=$(echo "$mem_info" | awk '{print $2}')

    log_info "Mémoire: $mem_used / $mem_total utilisée"
    return 0
}

################################################################################
# Fonction helper: Check Network
################################################################################
check_network() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        log_info "✅ Connectivité réseau OK"
        return 0
    else
        log_warn "⚠️  Pas de connectivité réseau"
        return 1
    fi
}

################################################################################
# Main
################################################################################
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        return 1
    fi

    local command="$1"
    shift

    case "$command" in
        status)
            cmd_status "$@"
            ;;
        create-user)
            cmd_create_user "$@"
            ;;
        delete-user)
            cmd_delete_user "$@"
            ;;
        install)
            cmd_install "$@"
            ;;
        remove)
            cmd_remove "$@"
            ;;
        list-services)
            cmd_list_services "$@"
            ;;
        enable-service)
            cmd_enable_service "$@"
            ;;
        disable-service)
            cmd_disable_service "$@"
            ;;
        restart-service)
            cmd_restart_service "$@"
            ;;
        check-disk)
            cmd_check_disk "$@"
            ;;
        health-check)
            cmd_health_check "$@"
            ;;
        version)
            echo "Server Manager v$VERSION"
            ;;
        -h|--help)
            show_usage
            ;;
        -v|--verbose)
            DEBUG=1
            log_info "Mode debug activé"
            ;;
        *)
            log_error "Commande inconnue: $command"
            show_usage
            return 1
            ;;
    esac
}

# Lancer le script
main "$@"
