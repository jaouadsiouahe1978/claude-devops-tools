#!/bin/bash

################################################################################
# Exemple: Créer un utilisateur avec clé SSH
# Usage: ./create-user-example.sh
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"
source "${SCRIPT_DIR}/modules/users.sh"

################################################################################
# Créer un nouvel utilisateur DevOps
################################################################################

USERNAME="devops"
GROUPS=("sudo" "docker")
PUBLIC_KEY_FILE="${1:-.ssh/id_rsa.pub}"

log_info "=== CRÉATION UTILISATEUR DEVOPS ==="

# 1. Créer l'utilisateur
log_info "Création de l'utilisateur: $USERNAME"
if create_user "$USERNAME"; then
    log_info "✅ Utilisateur créé"
else
    log_error "❌ Impossible de créer l'utilisateur"
    exit 1
fi

# 2. Ajouter aux groupes
for group in "${GROUPS[@]}"; do
    log_info "Ajout du groupe: $group"
    if add_user_to_group "$USERNAME" "$group"; then
        log_info "✅ Groupe ajouté"
    else
        log_warn "⚠️  Groupe non disponible: $group"
    fi
done

# 3. Configurer la clé SSH (optionnel)
if [[ -f "$PUBLIC_KEY_FILE" ]]; then
    log_info "Configuration de la clé SSH..."
    SSH_DIR="/home/$USERNAME/.ssh"

    sudo mkdir -p "$SSH_DIR"
    sudo cp "$PUBLIC_KEY_FILE" "$SSH_DIR/authorized_keys"
    sudo chmod 600 "$SSH_DIR/authorized_keys"
    sudo chown "$USERNAME:$USERNAME" "$SSH_DIR/authorized_keys"

    log_info "✅ Clé SSH configurée"
else
    log_warn "Fichier de clé publique non trouvé: $PUBLIC_KEY_FILE"
fi

# 4. Vérifier l'utilisateur
log_info "Vérification de l'utilisateur..."
get_user_info "$USERNAME"

log_info "✅ Configuration terminée!"
