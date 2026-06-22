#!/bin/bash

################################################################################
# Server Configuration - Variables globales et paramètres
################################################################################

# Version de l'application
VERSION="1.0.0"

# Répertoires
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs"
CONFIG_DIR="${PROJECT_ROOT}/config"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
MODULES_DIR="${PROJECT_ROOT}/modules"

# Fichier de log principal
LOG_FILE="${LOG_DIR}/server-manager.log"

# Rotation des logs (en jours)
LOG_RETENTION_DAYS=30

# Seuils d'alerte
DISK_USAGE_THRESHOLD=80      # Pourcentage
MEMORY_USAGE_THRESHOLD=85    # Pourcentage
CPU_LOAD_THRESHOLD=8         # Multiplié par le nombre de CPU

# Gestionnaire de paquets (auto-détecté)
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL_CMD="sudo apt-get install -y"
    PKG_REMOVE_CMD="sudo apt-get remove -y"
    PKG_UPDATE_CMD="sudo apt-get update"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    PKG_INSTALL_CMD="sudo yum install -y"
    PKG_REMOVE_CMD="sudo yum remove -y"
    PKG_UPDATE_CMD="sudo yum update"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_INSTALL_CMD="sudo dnf install -y"
    PKG_REMOVE_CMD="sudo dnf remove -y"
    PKG_UPDATE_CMD="sudo dnf update"
else
    PKG_MANAGER="unknown"
    PKG_INSTALL_CMD="echo 'Gestionnaire de paquets non trouvé'"
fi

# Configuration de logging
DEBUG="${DEBUG:-0}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR

# Email pour les alertes (optionnel)
ALERT_EMAIL="${ALERT_EMAIL:-}"

# Slack Webhook pour les notifications (optionnel)
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"

# Créer le répertoire logs s'il n'existe pas
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"

# Utilisateurs système à protéger (ne pas supprimer)
PROTECTED_USERS=(
    "root"
    "daemon"
    "bin"
    "sys"
    "sync"
    "games"
    "man"
    "lp"
    "mail"
    "news"
    "uucp"
    "proxy"
    "www-data"
    "backup"
    "list"
    "irc"
    "gnats"
    "systemd-network"
    "systemd-resolve"
    "messagebus"
    "syslog"
    "ubuntu"
    "_apt"
    "nobody"
)

# Services critiques à protéger (ne pas désactiver)
CRITICAL_SERVICES=(
    "sshd"
    "ssh"
    "systemd-logind"
    "networking"
)

# Export des variables pour les modules
export LOG_DIR LOG_FILE DEBUG LOG_LEVEL
export DISK_USAGE_THRESHOLD MEMORY_USAGE_THRESHOLD CPU_LOAD_THRESHOLD
export PKG_MANAGER PKG_INSTALL_CMD PKG_REMOVE_CMD PKG_UPDATE_CMD
export PROJECT_ROOT CONFIG_DIR SCRIPTS_DIR MODULES_DIR
export ALERT_EMAIL SLACK_WEBHOOK
