#!/bin/bash
# Utility functions for log monitoring

source "${CONFIG_FILE:-./config/log-monitor.conf}"

# Logging avec timestamp
log() {
    local level=$1
    shift
    local msg="$*"
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] [$level] $msg"
    [[ $DEBUG -eq 1 ]] && echo "[$ts] [$level] $msg" >> "${STATE_DIR}/debug.log"
}

# Créer les répertoires d'état si nécessaire
init_state_dirs() {
    mkdir -p "${STATE_DIR}" || {
        log "ERROR" "Impossible de créer $STATE_DIR"
        return 1
    }
    touch "${STATE_FILE}" 2>/dev/null || {
        log "ERROR" "Impossible de créer $STATE_FILE"
        return 1
    }
}

# Parser le fichier de configuration
load_config() {
    local config=$1
    if [[ ! -f "$config" ]]; then
        log "ERROR" "Fichier de config introuvable: $config"
        return 1
    fi
    source "$config" || {
        log "ERROR" "Erreur lors du parsing de $config"
        return 1
    }
    log "INFO" "Configuration chargée depuis $config"
}

# Vérifier si une alerte a été envoyée récemment (throttle)
should_alert() {
    local alert_key=$1
    local now=$(date +%s)
    local cache_file="${ALERT_CACHE}"

    if [[ ! -f "$cache_file" ]]; then
        echo "$alert_key:$now" >> "$cache_file"
        return 0
    fi

    local last_alert=$(grep "^${alert_key}:" "$cache_file" | cut -d: -f2)
    if [[ -z "$last_alert" ]]; then
        echo "$alert_key:$now" >> "$cache_file"
        return 0
    fi

    local diff=$((now - last_alert))
    if [[ $diff -gt ${ALERT_THROTTLE_SECONDS:-300} ]]; then
        # Mettre à jour le cache
        sed -i "/^${alert_key}:/d" "$cache_file"
        echo "$alert_key:$now" >> "$cache_file"
        return 0
    fi

    return 1
}

# Obtenir l'historique récent d'un log
get_context() {
    local logfile=$1
    local pattern=$2
    local lines=${HISTORY_LINES:-20}

    if [[ -f "$logfile" ]]; then
        grep -E "$pattern" "$logfile" | tail -n "$lines"
    fi
}

# Envoyer une alerte email
send_mail_alert() {
    local recipient=$1
    local subject=$2
    local body=$3
    local from=${ALERT_FROM:-"log-monitor@localhost"}

    {
        echo "From: $from"
        echo "To: $recipient"
        echo "Subject: $subject"
        echo "Date: $(date -R)"
        echo ""
        echo "$body"
    } | sendmail -t -i 2>/dev/null || {
        log "ERROR" "Impossible d'envoyer l'email à $recipient"
        return 1
    }

    log "INFO" "Alerte envoyée à $recipient"
    return 0
}

# Envoyer une alerte webhook
send_webhook_alert() {
    local webhook_url=$1
    local subject=$2
    local body=$3
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local payload=$(cat <<EOF
{
    "timestamp": "$timestamp",
    "alert": "$subject",
    "details": "$body",
    "severity": "high"
}
EOF
)

    curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null || {
        log "ERROR" "Impossible d'envoyer le webhook"
        return 1
    }

    log "INFO" "Alerte webhook envoyée"
    return 0
}

# Envoyer une alerte Slack
send_slack_alert() {
    local webhook_url=$1
    local subject=$2
    local body=$3

    local payload=$(cat <<'EOF'
{
    "text": "🚨 Log Alert",
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*SUBJECT*\n`BODY`"
            }
        }
    ]
}
EOF
)

    payload="${payload//SUBJECT/$subject}"
    payload="${payload//BODY/$body}"

    curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null || {
        log "ERROR" "Impossible d'envoyer l'alerte Slack"
        return 1
    }

    log "INFO" "Alerte Slack envoyée"
    return 0
}

# Interface uniforme pour envoyer une alerte
send_alert() {
    local alert_type=$1
    local subject=$2
    local body=$3

    case "${ALERT_METHOD:-mail}" in
        mail)
            send_mail_alert "${ALERT_EMAIL}" "${ALERT_SUBJECT_PREFIX} $subject" "$body"
            ;;
        webhook)
            send_webhook_alert "${WEBHOOK_URL}" "$subject" "$body"
            ;;
        slack)
            send_slack_alert "${SLACK_WEBHOOK}" "$subject" "$body"
            ;;
        *)
            log "ERROR" "Méthode d'alerte inconnue: ${ALERT_METHOD}"
            return 1
            ;;
    esac
}

# Nettoyer les fichiers de cache anciens
cleanup_cache() {
    if [[ -f "${ALERT_CACHE}" ]]; then
        local now=$(date +%s)
        local max_age=$((7 * 24 * 3600))  # 7 jours

        while IFS=: read -r key timestamp; do
            local age=$((now - timestamp))
            if [[ $age -gt $max_age ]]; then
                sed -i "/^${key}:/d" "${ALERT_CACHE}"
            fi
        done < "${ALERT_CACHE}"
    fi
}

# Afficher la version
show_version() {
    echo "Log Monitor v1.0"
    echo "Bash Log Monitoring & Alerting System"
}

# Afficher l'aide
show_help() {
    cat <<EOF
Usage: log-monitor.sh [OPTIONS]

Options:
    -c, --config FILE       Fichier de configuration (défaut: ./config/log-monitor.conf)
    -f, --foreground        Lancer en foreground (défaut: background daemon)
    -d, --debug             Activer le mode debug
    -h, --help              Afficher cette aide
    -v, --version           Afficher la version

Examples:
    # Lancer comme daemon
    log-monitor.sh -c config/log-monitor.conf

    # Lancer en foreground avec debug
    log-monitor.sh -c config/log-monitor.conf -f -d

    # Arrêter le daemon
    sudo systemctl stop log-monitor
EOF
}

export -f log
export -f init_state_dirs
export -f load_config
export -f should_alert
export -f get_context
export -f send_alert
export -f cleanup_cache
