#!/bin/bash
# Script d'administration pour le service systemd

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="mon-app"
INSTALL_DIR="/opt/my-app"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier les droits root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Cette commande doit être exécutée en tant que root${NC}"
        exit 1
    fi
}

# Afficher l'aide
usage() {
    cat << EOF
Usage: $0 <commande>

Commandes disponibles:
    install     - Installer et activer le service
    uninstall   - Désinstaller le service
    start       - Démarrer le service
    stop        - Arrêter le service
    restart     - Redémarrer le service
    status      - Afficher le statut
    logs        - Afficher les logs en temps réel
    logs-all    - Afficher tous les logs historiques
    timer-list  - Lister les executions du timer
    timer-reset - Réinitialiser le timer
    enable      - Activer au démarrage
    disable     - Désactiver du démarrage
    health      - Exécuter les health checks
    reload      - Recharger les configurations systemd

Exemples:
    sudo $0 install
    sudo $0 logs
    sudo $0 status
EOF
    exit 0
}

# Installer le service
install_service() {
    check_root
    echo -e "${BLUE}[*] Installation du service...${NC}"

    # Créer le répertoire d'installation
    mkdir -p "$INSTALL_DIR"

    # Copier les fichiers
    cp "$SCRIPT_DIR/app.py" "$INSTALL_DIR/"
    cp "$SCRIPT_DIR/monitoring.py" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/app.py"
    chmod +x "$INSTALL_DIR/monitoring.py"

    # Copier les fichiers systemd
    cp "$SCRIPT_DIR/$SERVICE_NAME.service" "/etc/systemd/system/"
    cp "$SCRIPT_DIR/$SERVICE_NAME.timer" "/etc/systemd/system/"

    # Recharger systemd
    systemctl daemon-reload

    # Activer les services
    systemctl enable "$SERVICE_NAME.service"
    systemctl enable "$SERVICE_NAME.timer"

    echo -e "${GREEN}[✓] Service installé avec succès${NC}"
    echo -e "${YELLOW}[!] Prochaine étape: sudo $0 start${NC}"
}

# Désinstaller le service
uninstall_service() {
    check_root
    echo -e "${BLUE}[*] Désinstallation du service...${NC}"

    # Arrêter les services
    systemctl stop "$SERVICE_NAME.service" || true
    systemctl stop "$SERVICE_NAME.timer" || true

    # Désactiver
    systemctl disable "$SERVICE_NAME.service" || true
    systemctl disable "$SERVICE_NAME.timer" || true

    # Supprimer les fichiers systemd
    rm -f "/etc/systemd/system/$SERVICE_NAME.service"
    rm -f "/etc/systemd/system/$SERVICE_NAME.timer"

    # Recharger systemd
    systemctl daemon-reload

    echo -e "${GREEN}[✓] Service désinstallé${NC}"
}

# Démarrer le service
start_service() {
    check_root
    echo -e "${BLUE}[*] Démarrage du service...${NC}"
    systemctl start "$SERVICE_NAME.service"
    echo -e "${GREEN}[✓] Service démarré${NC}"
}

# Arrêter le service
stop_service() {
    check_root
    echo -e "${BLUE}[*] Arrêt du service...${NC}"
    systemctl stop "$SERVICE_NAME.service"
    echo -e "${GREEN}[✓] Service arrêté${NC}"
}

# Redémarrer le service
restart_service() {
    check_root
    echo -e "${BLUE}[*] Redémarrage du service...${NC}"
    systemctl restart "$SERVICE_NAME.service"
    echo -e "${GREEN}[✓] Service redémarré${NC}"
}

# Afficher le statut
show_status() {
    echo -e "${BLUE}=== Statut du Service ===${NC}"
    systemctl status "$SERVICE_NAME.service" || true
    echo ""
    echo -e "${BLUE}=== Statut du Timer ===${NC}"
    systemctl status "$SERVICE_NAME.timer" || true
}

# Afficher les logs en temps réel
show_logs() {
    echo -e "${BLUE}[*] Affichage des logs (Ctrl+C pour quitter)...${NC}"
    journalctl -u "$SERVICE_NAME" -f
}

# Afficher tous les logs
show_all_logs() {
    echo -e "${BLUE}[*] Tous les logs du service:${NC}"
    journalctl -u "$SERVICE_NAME" --no-pager
}

# Lister les executions du timer
list_timer() {
    echo -e "${BLUE}[*] Exécutions du timer:${NC}"
    systemctl list-timers "$SERVICE_NAME.timer" --all
}

# Réinitialiser le timer
reset_timer() {
    check_root
    echo -e "${BLUE}[*] Réinitialisation du timer...${NC}"
    systemctl stop "$SERVICE_NAME.timer"
    systemctl start "$SERVICE_NAME.timer"
    echo -e "${GREEN}[✓] Timer réinitialisé${NC}"
}

# Activer au démarrage
enable_service() {
    check_root
    echo -e "${BLUE}[*] Activation au démarrage...${NC}"
    systemctl enable "$SERVICE_NAME.service"
    echo -e "${GREEN}[✓] Service activé au démarrage${NC}"
}

# Désactiver du démarrage
disable_service() {
    check_root
    echo -e "${BLUE}[*] Désactivation du démarrage...${NC}"
    systemctl disable "$SERVICE_NAME.service"
    echo -e "${GREEN}[✓] Service désactivé du démarrage${NC}"
}

# Recharger les configurations
reload_config() {
    check_root
    echo -e "${BLUE}[*] Rechargement des configurations...${NC}"
    systemctl daemon-reload
    echo -e "${GREEN}[✓] Configurations rechargées${NC}"
}

# Exécuter les health checks
run_health_check() {
    echo -e "${BLUE}[*] Exécution des health checks...${NC}"
    python3 "$SCRIPT_DIR/monitoring.py"
}

# Main
main() {
    if [[ $# -eq 0 ]]; then
        usage
    fi

    case "$1" in
        install) install_service ;;
        uninstall) uninstall_service ;;
        start) start_service ;;
        stop) stop_service ;;
        restart) restart_service ;;
        status) show_status ;;
        logs) show_logs ;;
        logs-all) show_all_logs ;;
        timer-list) list_timer ;;
        timer-reset) reset_timer ;;
        enable) enable_service ;;
        disable) disable_service ;;
        health) run_health_check ;;
        reload) reload_config ;;
        *)
            echo -e "${RED}Commande inconnue: $1${NC}"
            usage
            ;;
    esac
}

main "$@"
