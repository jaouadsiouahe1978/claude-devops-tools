#!/bin/bash

################################################################################
# Users Module - Gestion des utilisateurs Linux
################################################################################

################################################################################
# create_user - Crée un nouvel utilisateur
# Usage: create_user "username"
################################################################################
create_user() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: create_user <username>"
        return 1
    fi

    if id "$username" &>/dev/null; then
        log_warn "L'utilisateur $username existe déjà"
        return 0
    fi

    log_debug "Création de l'utilisateur: $username"

    if sudo useradd -m -s /bin/bash "$username"; then
        log_info "Utilisateur créé avec succès" "user=$username"

        # Créer le répertoire .ssh
        sudo mkdir -p "/home/$username/.ssh"
        sudo chown "$username:$username" "/home/$username/.ssh"
        sudo chmod 700 "/home/$username/.ssh"

        return 0
    else
        log_error "Impossible de créer l'utilisateur" "user=$username"
        return 1
    fi
}

################################################################################
# delete_user - Supprime un utilisateur
# Usage: delete_user "username"
################################################################################
delete_user() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: delete_user <username>"
        return 1
    fi

    # Vérifier que c'est pas un utilisateur protégé
    for protected in "${PROTECTED_USERS[@]}"; do
        if [[ "$username" == "$protected" ]]; then
            log_error "Impossible de supprimer l'utilisateur protégé: $username"
            return 1
        fi
    done

    if ! id "$username" &>/dev/null; then
        log_warn "L'utilisateur $username n'existe pas"
        return 0
    fi

    log_debug "Suppression de l'utilisateur: $username"

    if sudo userdel -r "$username"; then
        log_info "Utilisateur supprimé avec succès" "user=$username"
        return 0
    else
        log_error "Impossible de supprimer l'utilisateur" "user=$username"
        return 1
    fi
}

################################################################################
# add_user_to_group - Ajoute un utilisateur à un groupe
# Usage: add_user_to_group "username" "groupname"
################################################################################
add_user_to_group() {
    local username="$1"
    local groupname="$2"

    if [[ -z "$username" || -z "$groupname" ]]; then
        log_error "Usage: add_user_to_group <username> <groupname>"
        return 1
    fi

    log_debug "Ajout de $username au groupe $groupname"

    if sudo usermod -aG "$groupname" "$username"; then
        log_info "Utilisateur ajouté au groupe" "user=$username group=$groupname"
        return 0
    else
        log_error "Impossible d'ajouter l'utilisateur au groupe" "user=$username group=$groupname"
        return 1
    fi
}

################################################################################
# list_users - Liste tous les utilisateurs avec UID >= 1000
################################################################################
list_users() {
    log_info "=== UTILISATEURS ACTIFS ==="
    awk -F':' '$3 >= 1000 { printf "%-20s UID:%-6s GID:%-6s\n", $1, $3, $4 }' /etc/passwd
}

################################################################################
# change_user_password - Change le mot de passe d'un utilisateur
# Usage: change_user_password "username" "password"
################################################################################
change_user_password() {
    local username="$1"
    local password="$2"

    if [[ -z "$username" || -z "$password" ]]; then
        log_error "Usage: change_user_password <username> <password>"
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        log_error "L'utilisateur n'existe pas: $username"
        return 1
    fi

    echo "$username:$password" | sudo chpasswd

    if [[ $? -eq 0 ]]; then
        log_info "Mot de passe changé avec succès" "user=$username"
        return 0
    else
        log_error "Impossible de changer le mot de passe" "user=$username"
        return 1
    fi
}

################################################################################
# get_user_info - Affiche les info d'un utilisateur
# Usage: get_user_info "username"
################################################################################
get_user_info() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: get_user_info <username>"
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        log_error "L'utilisateur n'existe pas: $username"
        return 1
    fi

    log_info "=== INFO UTILISATEUR: $username ==="
    id "$username"
    echo ""
    echo "Home directory: $(eval echo ~$username)"
    echo "Shell: $(grep "^$username:" /etc/passwd | cut -d':' -f7)"
    echo "Last login: $(lastlog -u "$username" | tail -1)"
}

################################################################################
# list_user_groups - Liste les groupes d'un utilisateur
# Usage: list_user_groups "username"
################################################################################
list_user_groups() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: list_user_groups <username>"
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        log_error "L'utilisateur n'existe pas: $username"
        return 1
    fi

    log_info "Groupes de $username:"
    groups "$username"
}

################################################################################
# disable_user - Désactive un utilisateur
# Usage: disable_user "username"
################################################################################
disable_user() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: disable_user <username>"
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        log_error "L'utilisateur n'existe pas: $username"
        return 1
    fi

    log_debug "Désactivation de l'utilisateur: $username"

    if sudo usermod -L "$username"; then
        log_info "Utilisateur désactivé" "user=$username"
        return 0
    else
        log_error "Impossible de désactiver l'utilisateur" "user=$username"
        return 1
    fi
}

################################################################################
# enable_user - Réactive un utilisateur
# Usage: enable_user "username"
################################################################################
enable_user() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: enable_user <username>"
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        log_error "L'utilisateur n'existe pas: $username"
        return 1
    fi

    log_debug "Réactivation de l'utilisateur: $username"

    if sudo usermod -U "$username"; then
        log_info "Utilisateur réactivé" "user=$username"
        return 0
    else
        log_error "Impossible de réactiver l'utilisateur" "user=$username"
        return 1
    fi
}

log_debug "Module users chargé"
