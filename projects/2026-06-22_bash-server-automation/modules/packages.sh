#!/bin/bash

################################################################################
# Packages Module - Gestion des paquets logiciels
################################################################################

################################################################################
# install_packages - Installe des paquets
# Usage: install_packages "package1" "package2" ...
################################################################################
install_packages() {
    if [[ $# -eq 0 ]]; then
        log_error "Usage: install_packages <package1> [package2] ..."
        return 1
    fi

    local packages=("$@")

    log_info "Mise à jour du cache de paquets..."
    if ! $PKG_UPDATE_CMD &>/dev/null; then
        log_warn "Impossible de mettre à jour le cache"
    fi

    for package in "${packages[@]}"; do
        log_debug "Installation du paquet: $package"

        if $PKG_INSTALL_CMD "$package" &>/dev/null; then
            log_info "Paquet installé avec succès" "package=$package"
        else
            log_error "Impossible d'installer le paquet" "package=$package"
        fi
    done
}

################################################################################
# remove_packages - Supprime des paquets
# Usage: remove_packages "package1" "package2" ...
################################################################################
remove_packages() {
    if [[ $# -eq 0 ]]; then
        log_error "Usage: remove_packages <package1> [package2] ..."
        return 1
    fi

    local packages=("$@")

    for package in "${packages[@]}"; do
        log_debug "Suppression du paquet: $package"

        if $PKG_REMOVE_CMD "$package" &>/dev/null; then
            log_info "Paquet supprimé avec succès" "package=$package"
        else
            log_warn "Paquet non trouvé ou impossible à supprimer" "package=$package"
        fi
    done
}

################################################################################
# is_package_installed - Vérifie si un paquet est installé
# Usage: is_package_installed "package"
################################################################################
is_package_installed() {
    local package="$1"

    if [[ -z "$package" ]]; then
        log_error "Usage: is_package_installed <package>"
        return 1
    fi

    case "$PKG_MANAGER" in
        apt)
            dpkg -l | grep -q "^ii.*$package" && return 0 || return 1
            ;;
        yum|dnf)
            rpm -q "$package" &>/dev/null && return 0 || return 1
            ;;
        *)
            log_error "Gestionnaire de paquets non supporté: $PKG_MANAGER"
            return 1
            ;;
    esac
}

################################################################################
# list_installed_packages - Liste tous les paquets installés
################################################################################
list_installed_packages() {
    log_info "=== PAQUETS INSTALLÉS ==="

    case "$PKG_MANAGER" in
        apt)
            dpkg -l | grep '^ii' | awk '{print $2, "(" $3 ")"}'
            ;;
        yum|dnf)
            rpm -qa --queryformat '%{NAME} (%{VERSION}-%{RELEASE})\n'
            ;;
        *)
            log_error "Gestionnaire de paquets non supporté: $PKG_MANAGER"
            return 1
            ;;
    esac
}

################################################################################
# count_installed_packages - Compte le nombre de paquets installés
################################################################################
count_installed_packages() {
    case "$PKG_MANAGER" in
        apt)
            dpkg -l | grep '^ii' | wc -l
            ;;
        yum|dnf)
            rpm -qa | wc -l
            ;;
        *)
            echo "0"
            ;;
    esac
}

################################################################################
# list_available_updates - Liste les mises à jour disponibles
################################################################################
list_available_updates() {
    log_info "=== MISES À JOUR DISPONIBLES ==="

    case "$PKG_MANAGER" in
        apt)
            apt-get update &>/dev/null
            apt list --upgradable 2>/dev/null || echo "Pas de mise à jour disponible"
            ;;
        yum)
            yum check-update 2>/dev/null || echo "Pas de mise à jour disponible"
            ;;
        dnf)
            dnf check-update 2>/dev/null || echo "Pas de mise à jour disponible"
            ;;
        *)
            log_error "Gestionnaire de paquets non supporté: $PKG_MANAGER"
            return 1
            ;;
    esac
}

################################################################################
# upgrade_all_packages - Upgrade tous les paquets
################################################################################
upgrade_all_packages() {
    log_warn "Upgrade de tous les paquets..."

    case "$PKG_MANAGER" in
        apt)
            sudo apt-get upgrade -y
            ;;
        yum)
            sudo yum update -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        *)
            log_error "Gestionnaire de paquets non supporté: $PKG_MANAGER"
            return 1
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        log_info "Upgrade effectué avec succès"
    else
        log_error "Erreur lors de l'upgrade"
    fi
}

################################################################################
# search_package - Cherche un paquet dans les dépôts
# Usage: search_package "search_term"
################################################################################
search_package() {
    local search_term="$1"

    if [[ -z "$search_term" ]]; then
        log_error "Usage: search_package <search_term>"
        return 1
    fi

    log_info "Recherche du paquet: $search_term"

    case "$PKG_MANAGER" in
        apt)
            apt-cache search "$search_term"
            ;;
        yum)
            yum search "$search_term" 2>/dev/null
            ;;
        dnf)
            dnf search "$search_term" 2>/dev/null
            ;;
        *)
            log_error "Gestionnaire de paquets non supporté: $PKG_MANAGER"
            return 1
            ;;
    esac
}

################################################################################
# get_package_info - Affiche les infos d'un paquet
# Usage: get_package_info "package"
################################################################################
get_package_info() {
    local package="$1"

    if [[ -z "$package" ]]; then
        log_error "Usage: get_package_info <package>"
        return 1
    fi

    log_info "=== INFO PAQUET: $package ==="

    case "$PKG_MANAGER" in
        apt)
            apt-cache show "$package" | head -20
            ;;
        yum)
            yum info "$package" 2>/dev/null
            ;;
        dnf)
            dnf info "$package" 2>/dev/null
            ;;
        *)
            log_error "Gestionnaire de paquets non supporté: $PKG_MANAGER"
            return 1
            ;;
    esac
}

log_debug "Module packages chargé"
