#!/bin/bash

################################################################################
# Disk Module - Monitoring et gestion des disques
################################################################################

################################################################################
# show_disk_usage - Affiche l'utilisation disque
################################################################################
show_disk_usage() {
    log_info "=== UTILISATION DISQUE ==="
    df -h | awk 'NR==1 || NF' | column -t
}

################################################################################
# check_disk_usage - Vérifie si le disque dépasse le seuil d'alerte
################################################################################
check_disk_usage() {
    log_info "=== VÉRIFICATION DISQUE ==="

    local disk_status=0

    df -h | tail -n +2 | while read line; do
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        local filesystem=$(echo "$line" | awk '{print $6}')

        log_debug "Vérification: $filesystem ($usage%)"

        if (( usage >= DISK_USAGE_THRESHOLD )); then
            log_warn "⚠️  Disque $filesystem utilisation critique" "filesystem=$filesystem usage=${usage}%"
            disk_status=1
        else
            log_info "✅ $filesystem OK" "usage=${usage}%"
        fi
    done

    return $disk_status
}

################################################################################
# list_disk_partitions - Liste toutes les partitions
################################################################################
list_disk_partitions() {
    log_info "=== PARTITIONS DISQUE ==="
    fdisk -l 2>/dev/null | grep -E "^Disk /dev" || parted -l 2>/dev/null || echo "Impossible de lister les partitions"
}

################################################################################
# get_inode_usage - Affiche l'utilisation des inodes
################################################################################
get_inode_usage() {
    log_info "=== UTILISATION DES INODES ==="
    df -i | awk 'NR==1 || NF' | column -t
}

################################################################################
# show_large_files - Liste les N fichiers les plus gros
# Usage: show_large_files [directory] [count]
################################################################################
show_large_files() {
    local directory="${1:-.}"
    local count="${2:-20}"

    log_info "=== $count PLUS GROS FICHIERS dans $directory ==="

    find "$directory" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n "$count"
}

################################################################################
# show_large_directories - Liste les N répertoires les plus gros
# Usage: show_large_directories [directory] [count]
################################################################################
show_large_directories() {
    local directory="${1:-/}"
    local count="${2:-20}"

    log_info "=== $count PLUS GROS RÉPERTOIRES dans $directory ==="

    du -sh "$directory"/* 2>/dev/null | sort -rh | head -n "$count"
}

################################################################################
# clean_log_files - Nettoie les vieux fichiers logs
# Usage: clean_log_files [directory] [days]
################################################################################
clean_log_files() {
    local directory="${1:-/var/log}"
    local days="${2:-30}"

    log_warn "Suppression des fichiers logs plus vieux que $days jours dans $directory"

    if [[ -d "$directory" ]]; then
        find "$directory" -name "*.log*" -mtime "+$days" -delete
        log_info "Nettoyage effectué"
    else
        log_error "Répertoire non trouvé: $directory"
        return 1
    fi
}

################################################################################
# analyze_disk_io - Affiche les stats I/O disque
################################################################################
analyze_disk_io() {
    log_info "=== STATISTIQUES I/O DISQUE ==="

    if command -v iostat &>/dev/null; then
        iostat -x 2 2 | tail -n +3
    else
        # Fallback si iostat n'est pas disponible
        cat /proc/diskstats | awk '{print $3, $6, $8}' | column -t
    fi
}

################################################################################
# monitor_disk_fill_rate - Monitore la vitesse de remplissage du disque
# Usage: monitor_disk_fill_rate [interval] [iterations]
################################################################################
monitor_disk_fill_rate() {
    local interval="${1:-60}"
    local iterations="${2:-5}"

    log_info "Monitoring du taux de remplissage du disque"
    log_info "Intervalle: ${interval}s, Itérations: $iterations"

    for ((i=1; i<=iterations; i++)); do
        local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        echo "[$(date '+%H:%M:%S')] Utilisation: ${usage}%"

        if [[ $i -lt $iterations ]]; then
            sleep "$interval"
        fi
    done
}

################################################################################
# show_mounted_filesystems - Liste tous les systèmes de fichiers montés
################################################################################
show_mounted_filesystems() {
    log_info "=== SYSTÈMES DE FICHIERS MONTÉS ==="
    mount | column -t -s' ' | grep -E "^/dev"
}

################################################################################
# check_disk_errors - Vérifie les erreurs disque
################################################################################
check_disk_errors() {
    log_info "=== VÉRIFICATION DES ERREURS DISQUE ==="

    if command -v smartctl &>/dev/null; then
        # SMART stats si disponible
        for disk in /dev/sd*; do
            if [[ -b "$disk" ]]; then
                log_info "Vérification SMART pour $disk"
                sudo smartctl -H "$disk" 2>/dev/null || echo "SMART non supporté pour $disk"
            fi
        done
    else
        log_warn "smartctl non trouvé. Les statistiques SMART ne sont pas disponibles."
    fi
}

################################################################################
# get_disk_space_summary - Résumé simple de l'espace disque
################################################################################
get_disk_space_summary() {
    log_info "=== RÉSUMÉ ESPACE DISQUE ==="

    local total=$(df / | tail -1 | awk '{print $2}')
    local used=$(df / | tail -1 | awk '{print $3}')
    local available=$(df / | tail -1 | awk '{print $4}')
    local percent=$(df / | tail -1 | awk '{print $5}')

    echo "Total:      $(numfmt --to=iec-i --suffix=B $((total * 1024)) 2>/dev/null || echo $total KB)"
    echo "Utilisé:    $(numfmt --to=iec-i --suffix=B $((used * 1024)) 2>/dev/null || echo $used KB)"
    echo "Disponible: $(numfmt --to=iec-i --suffix=B $((available * 1024)) 2>/dev/null || echo $available KB)"
    echo "Pourcentage: $percent"
}

log_debug "Module disk chargé"
