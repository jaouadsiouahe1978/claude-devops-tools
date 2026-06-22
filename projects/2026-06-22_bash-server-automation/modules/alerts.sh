#!/bin/bash

################################################################################
# Alerts Module - Système d'alertes et notifications
################################################################################

################################################################################
# send_alert_email - Envoie une alerte par email
# Usage: send_alert_email "subject" "message"
################################################################################
send_alert_email() {
    local subject="$1"
    local message="$2"

    if [[ -z "$ALERT_EMAIL" ]]; then
        log_debug "Email d'alerte non configuré"
        return 0
    fi

    if ! command -v mail &>/dev/null; then
        log_warn "Commande 'mail' non trouvée"
        return 1
    fi

    log_debug "Envoi d'alerte email à $ALERT_EMAIL"

    echo "$message" | mail -s "🚨 SERVER ALERT: $subject" "$ALERT_EMAIL"

    if [[ $? -eq 0 ]]; then
        log_info "Alerte email envoyée" "recipient=$ALERT_EMAIL"
    else
        log_error "Impossible d'envoyer l'alerte email"
    fi
}

################################################################################
# send_slack_alert - Envoie une alerte Slack
# Usage: send_slack_alert "message"
################################################################################
send_slack_alert() {
    local message="$1"
    local severity="${2:-warning}"

    if [[ -z "$SLACK_WEBHOOK" ]]; then
        log_debug "Slack webhook non configuré"
        return 0
    fi

    # Déterminer la couleur selon la sévérité
    local color="warning"
    case "$severity" in
        critical)
            color="danger"
            ;;
        info)
            color="good"
            ;;
        warning)
            color="warning"
            ;;
    esac

    log_debug "Envoi d'alerte Slack"

    local payload=$(cat <<EOF
{
    "attachments": [
        {
            "color": "$color",
            "title": "Server Alert",
            "text": "$message",
            "footer": "Server Manager",
            "ts": $(date +%s)
        }
    ]
}
EOF
)

    if curl -s -X POST -H 'Content-type: application/json' \
        --data "$payload" "$SLACK_WEBHOOK" &>/dev/null; then
        log_info "Alerte Slack envoyée"
    else
        log_error "Impossible d'envoyer l'alerte Slack"
    fi
}

################################################################################
# alert_if_disk_critical - Alerte si disque critique
# Usage: alert_if_disk_critical
################################################################################
alert_if_disk_critical() {
    local disk_percent=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

    if (( disk_percent >= 95 )); then
        local message="🚨 DISQUE CRITIQUE! Utilisation: ${disk_percent}%"
        send_slack_alert "$message" "critical"
        send_alert_email "DISK CRITICAL" "$message"
    elif (( disk_percent >= 90 )); then
        local message="⚠️  Disque haute utilisation: ${disk_percent}%"
        send_slack_alert "$message" "warning"
    fi
}

################################################################################
# alert_if_memory_critical - Alerte si mémoire critique
# Usage: alert_if_memory_critical
################################################################################
alert_if_memory_critical() {
    local mem_percent=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    if (( mem_percent >= 95 )); then
        local message="🚨 MÉMOIRE CRITIQUE! Utilisation: ${mem_percent}%"
        send_slack_alert "$message" "critical"
        send_alert_email "MEMORY CRITICAL" "$message"
    elif (( mem_percent >= 85 )); then
        local message="⚠️  Mémoire haute utilisation: ${mem_percent}%"
        send_slack_alert "$message" "warning"
    fi
}

################################################################################
# alert_if_service_down - Alerte si un service est down
# Usage: alert_if_service_down "service_name"
################################################################################
alert_if_service_down() {
    local service="$1"

    if [[ -z "$service" ]]; then
        log_error "Usage: alert_if_service_down <service_name>"
        return 1
    fi

    if ! systemctl is-active --quiet "$service"; then
        local message="🚨 SERVICE DOWN: $service n'est pas actif!"
        send_slack_alert "$message" "critical"
        send_alert_email "SERVICE DOWN: $service" "$message"
    fi
}

################################################################################
# alert_if_high_load - Alerte si charge système élevée
# Usage: alert_if_high_load
################################################################################
alert_if_high_load() {
    local load1=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local cpu_count=$(nproc)
    local load_limit=$(echo "$cpu_count * 1.5" | bc)

    if (( $(echo "$load1 > $load_limit" | bc -l) )); then
        local message="🚨 CHARGE SYSTÈME ÉLEVÉE! Load: $load1 (CPUs: $cpu_count)"
        send_slack_alert "$message" "critical"
        send_alert_email "HIGH SYSTEM LOAD" "$message"
    fi
}

################################################################################
# alert_custom - Alerte personnalisée
# Usage: alert_custom "message" [severity]
################################################################################
alert_custom() {
    local message="$1"
    local severity="${2:-warning}"

    log_warn "Alerte: $message"

    send_slack_alert "$message" "$severity"
    send_alert_email "CUSTOM ALERT" "$message"
}

################################################################################
# test_alerts - Teste le système d'alertes
################################################################################
test_alerts() {
    log_info "Test du système d'alertes..."

    echo "Test 1: Email alert"
    send_alert_email "TEST SUBJECT" "This is a test email alert"

    echo "Test 2: Slack alert"
    send_slack_alert "This is a test Slack alert" "info"

    echo "Test complet"
    log_info "Tests d'alertes effectués"
}

log_debug "Module alerts chargé"
