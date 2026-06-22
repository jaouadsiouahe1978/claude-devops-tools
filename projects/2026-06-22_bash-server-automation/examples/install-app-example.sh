#!/bin/bash

################################################################################
# Exemple: Installer une stack d'application (Docker + monitoring)
# Usage: ./install-app-example.sh
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"
source "${SCRIPT_DIR}/modules/packages.sh"
source "${SCRIPT_DIR}/modules/services.sh"

log_info "=== INSTALLATION STACK APPLICATION ==="

# Paquets à installer
PACKAGES=(
    "docker.io"
    "docker-compose"
    "git"
    "curl"
    "wget"
    "htop"
    "tmux"
    "vim"
    "jq"
)

# 1. Mettre à jour le système
log_info "📦 Mise à jour du système..."
if $PKG_UPDATE_CMD &>/dev/null; then
    log_info "✅ Système mis à jour"
else
    log_warn "⚠️  Impossible de mettre à jour"
fi

# 2. Installer les paquets
log_info "📦 Installation des paquets ($((${#PACKAGES[@]})) packages)..."
for package in "${PACKAGES[@]}"; do
    if is_package_installed "$package"; then
        log_info "✅ Déjà installé: $package"
    else
        log_info "Installation: $package"
        install_packages "$package"
    fi
done

# 3. Activer les services critiques
log_info "🔧 Configuration des services..."

if systemctl list-unit-files | grep -q docker; then
    enable_service "docker"
    start_service "docker"
    log_info "✅ Docker activé"
fi

# 4. Ajouter l'utilisateur courant au groupe docker (optionnel)
if [[ -n "${SUDO_USER:-}" ]]; then
    log_info "Ajout de $SUDO_USER au groupe docker..."
    sudo usermod -aG docker "$SUDO_USER"
    log_info "✅ L'utilisateur doit se reconnecter pour les changements de groupe"
fi

# 5. Vérifier les versions
log_info "✅ Installation terminée!"
echo ""
echo "Versions:"
docker --version || echo "Docker non disponible"
docker-compose --version || echo "Docker Compose non disponible"
git --version || echo "Git non disponible"

echo ""
log_info "Les services critiques sont maintenant actifs."
log_info "Prochaines étapes:"
log_info "  1. Cloner l'application: git clone <repo>"
log_info "  2. Lancer avec: docker-compose up -d"
log_info "  3. Vérifier les logs: docker-compose logs -f"
