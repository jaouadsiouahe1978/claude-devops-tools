#!/bin/bash

################################################################################
# Logging Module - Système centralisé de logs pour Server Manager
################################################################################

################################################################################
# log_info - Log un message d'information
# Usage: log_info "Message"
################################################################################
log_info() {
    local message="$1"
    local context="${2:-}"
    _write_log "INFO" "$message" "$context"
}

################################################################################
# log_warn - Log un avertissement
# Usage: log_warn "Message"
################################################################################
log_warn() {
    local message="$1"
    local context="${2:-}"
    _write_log "WARN" "$message" "$context"
}

################################################################################
# log_error - Log une erreur
# Usage: log_error "Message" "context_info"
################################################################################
log_error() {
    local message="$1"
    local context="${2:-}"
    _write_log "ERROR" "$message" "$context"
}

################################################################################
# log_debug - Log en mode debug seulement
# Usage: DEBUG=1 log_debug "Message"
################################################################################
log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        local message="$1"
        local context="${2:-}"
        _write_log "DEBUG" "$message" "$context"
    fi
}

################################################################################
# _write_log - Fonction interne d'écriture des logs
################################################################################
_write_log() {
    local level="$1"
    local message="$2"
    local context="$3"

    # Timestamp RFC 3339
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Caller info (nom de la fonction)
    local caller="${FUNCNAME[3]:-unknown}"

    # Format du log
    local log_line="[$timestamp] [$level] [$caller] $message"
    if [[ -n "$context" ]]; then
        log_line="$log_line | $context"
    fi

    # Écrire dans le fichier
    if [[ -w "$LOG_DIR" ]]; then
        echo "$log_line" >> "$LOG_FILE"
    fi

    # Afficher en console avec couleur
    _print_colored "$level" "$log_line"
}

################################################################################
# _print_colored - Affiche le log avec couleurs
################################################################################
_print_colored() {
    local level="$1"
    local message="$2"

    # Couleurs ANSI
    local red='\033[0;31m'
    local yellow='\033[1;33m'
    local green='\033[0;32m'
    local blue='\033[0;34m'
    local nc='\033[0m' # No Color

    case "$level" in
        ERROR)
            echo -e "${red}${message}${nc}" >&2
            ;;
        WARN)
            echo -e "${yellow}${message}${nc}" >&1
            ;;
        INFO)
            echo -e "${green}${message}${nc}" >&1
            ;;
        DEBUG)
            echo -e "${blue}${message}${nc}" >&1
            ;;
        *)
            echo "$message"
            ;;
    esac
}

################################################################################
# rotate_logs - Rotation des fichiers logs
# Supprime les logs plus vieux que LOG_RETENTION_DAYS
################################################################################
rotate_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        # Créer un backup compressé
        local backup_file="${LOG_FILE}.$(date +%Y%m%d_%H%M%S).gz"
        gzip -c "$LOG_FILE" > "$backup_file"

        # Vider le fichier courant
        > "$LOG_FILE"

        log_info "Rotation des logs effectuée" "backup=$backup_file"

        # Supprimer les vieux backups
        find "$LOG_DIR" -name "server-manager.log.*.gz" -mtime +$LOG_RETENTION_DAYS -delete
    fi
}

################################################################################
# tail_logs - Affiche les N dernières lignes du log
################################################################################
tail_logs() {
    local lines="${1:-20}"
    if [[ -f "$LOG_FILE" ]]; then
        echo "=== Dernières $lines lignes du log ($LOG_FILE) ==="
        tail -n "$lines" "$LOG_FILE"
    fi
}

################################################################################
# grep_logs - Grep dans les logs
################################################################################
grep_logs() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        log_error "Usage: grep_logs 'pattern'"
        return 1
    fi

    if [[ -f "$LOG_FILE" ]]; then
        grep -i "$pattern" "$LOG_FILE" || log_info "Aucune ligne ne correspond à: $pattern"
    fi
}

################################################################################
# stats_logs - Affiche les statistiques des logs
################################################################################
stats_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        echo "=== Statistiques des logs ==="
        echo "Fichier: $LOG_FILE"
        echo "Taille: $(du -h "$LOG_FILE" | cut -f1)"
        echo "Nombre de lignes: $(wc -l < "$LOG_FILE")"
        echo ""
        echo "Par niveau:"
        echo "  INFO:  $(grep -c '\[INFO\]' "$LOG_FILE" || echo 0)"
        echo "  WARN:  $(grep -c '\[WARN\]' "$LOG_FILE" || echo 0)"
        echo "  ERROR: $(grep -c '\[ERROR\]' "$LOG_FILE" || echo 0)"
        echo "  DEBUG: $(grep -c '\[DEBUG\]' "$LOG_FILE" || echo 0)"
    fi
}

# Initialiser le fichier log au premier load
if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
fi

log_debug "Module logging chargé"
