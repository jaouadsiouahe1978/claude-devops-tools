#!/bin/bash
# Main log monitoring script
# Usage: ./log-monitor.sh -c config/log-monitor.conf [-f] [-d]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE=""
FOREGROUND=0
DEBUG=0

source "$SCRIPT_DIR/utils.sh"

# Parser les arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -f|--foreground)
                FOREGROUND=1
                shift
                ;;
            -d|--debug)
                DEBUG=1
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            *)
                echo "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Initialiser le système
initialize() {
    CONFIG_FILE="${CONFIG_FILE:-${PROJECT_DIR}/config/log-monitor.conf}"

    load_config "$CONFIG_FILE" || exit 1
    init_state_dirs || exit 1

    log "INFO" "=== Log Monitor Starting ==="
    log "INFO" "Config: $CONFIG_FILE"
    log "INFO" "State Dir: $STATE_DIR"
    log "INFO" "Log Files: $LOG_FILES"
    log "INFO" "Alert Method: ${ALERT_METHOD:-mail}"
}

# Monitorer un fichier de log unique
monitor_logfile() {
    local logfile=$1

    if [[ ! -f "$logfile" ]]; then
        log "WARN" "Fichier de log introuvable: $logfile"
        return 1
    fi

    log "INFO" "Monitoring $logfile"

    tail -f "$logfile" 2>/dev/null | while read -r line; do
        check_line "$logfile" "$line"
    done
}

# Vérifier une ligne de log
check_line() {
    local logfile=$1
    local line=$2

    # Parcourir chaque pattern d'erreur
    for pattern_name in "${!ERROR_PATTERNS[@]}"; do
        local pattern="${ERROR_PATTERNS[$pattern_name]}"

        if [[ "$line" =~ $pattern ]]; then
            handle_error "$logfile" "$pattern_name" "$line"
        fi
    done
}

# Gérer une erreur détectée
handle_error() {
    local logfile=$1
    local pattern_name=$2
    local line=$3

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_key="${logfile}:${pattern_name}"

    log "WARN" "[$pattern_name] Détecté dans $logfile"

    # Throttle les alertes
    if ! should_alert "$alert_key"; then
        log "DEBUG" "Alerte throttled pour $alert_key"
        return
    fi

    # Construire le corps de l'alerte
    local subject="[$pattern_name] Erreur détectée dans $logfile"
    local context=$(get_context "$logfile" "$pattern" | tail -n 5)

    local body=$(cat <<EOF
Timestamp: $timestamp
Log File: $logfile
Pattern: $pattern_name

Error Line:
$line

Context (5 dernières lignes):
${context}

---
Log Monitor v1.0 - Automated Alert
EOF
)

    # Envoyer l'alerte
    send_alert "$pattern_name" "$subject" "$body" || {
        log "ERROR" "Impossible d'envoyer l'alerte"
    }
}

# Gestionnaire de signal pour arrêt gracieux
signal_handler() {
    log "INFO" "Arrêt du monitoring..."
    cleanup_cache
    log "INFO" "=== Log Monitor Stopped ==="
    exit 0
}

# Configuration des signaux
setup_signals() {
    trap signal_handler SIGTERM SIGINT SIGHUP
}

# Mode daemon (background)
daemonize() {
    if [[ $FOREGROUND -eq 0 ]]; then
        nohup "$0" "$@" -f >/dev/null 2>&1 &
        log "INFO" "Daemon lancé en background (PID: $!)"
        exit 0
    fi
}

# Boucle principale de monitoring
main_loop() {
    local -a log_files
    IFS=':' read -ra log_files <<< "$LOG_FILES"

    if [[ ${#log_files[@]} -eq 0 ]]; then
        log "ERROR" "Aucun fichier de log configuré"
        return 1
    fi

    log "INFO" "Démarrage de la surveillance de ${#log_files[@]} fichier(s)"

    # Monitorer chaque fichier en parallèle
    local pids=()
    for logfile in "${log_files[@]}"; do
        monitor_logfile "$logfile" &
        pids+=($!)
    done

    # Attendre que tous les processus se terminent
    wait "${pids[@]}" || true
}

# Point d'entrée principal
main() {
    parse_args "$@"
    initialize
    setup_signals
    daemonize "$@"

    log "INFO" "=== Boucle principale démarrée ==="
    main_loop

    log "INFO" "=== Log Monitor Terminated ==="
}

# Lancer le programme
main "$@"
