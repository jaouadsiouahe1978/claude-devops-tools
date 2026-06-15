#!/bin/bash

# Alert Manager
# Manages alert suppression, aggregation, and routing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/monitoring.conf"

source "$CONFIG_FILE"

# ============================================================
# ALERT CACHE (To avoid duplicate alerts)
# ============================================================

ALERT_CACHE="/tmp/alert-cache"
mkdir -p "$ALERT_CACHE"

get_alert_hash() {
    local message=$1
    echo -n "$message" | md5sum | awk '{print $1}'
}

is_alert_suppressed() {
    local hash=$1
    local cache_file="${ALERT_CACHE}/${hash}"

    if [[ -f "$cache_file" ]]; then
        local last_time=$(cat "$cache_file")
        local current_time=$(date +%s)
        local elapsed=$((current_time - last_time))

        if [[ $elapsed -lt $ALERT_COOLDOWN ]]; then
            return 0  # Alert is suppressed
        fi
    fi

    return 1  # Alert is not suppressed
}

mark_alert_sent() {
    local hash=$1
    local cache_file="${ALERT_CACHE}/${hash}"
    date +%s > "$cache_file"
}

# ============================================================
# ALERT FUNCTIONS
# ============================================================

send_alert() {
    local severity=$1
    local message=$2

    local hash=$(get_alert_hash "$message")

    if is_alert_suppressed "$hash"; then
        echo "[$(date '+%H:%M:%S')] SUPPRESSED: $message"
        return
    fi

    echo "[$(date '+%H:%M:%S')] SENDING: [$severity] $message"

    # Log alert
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$severity] $message" >> "$ALERT_LOG_FILE"

    # Send via webhook
    if [[ "$ENABLE_WEBHOOK" == "true" ]]; then
        send_slack_notification "$severity" "$message"
    fi

    mark_alert_sent "$hash"
}

send_slack_notification() {
    local severity=$1
    local message=$2

    local color="warning"
    [[ "$severity" == "ERROR" ]] && color="danger"
    [[ "$severity" == "CRITICAL" ]] && color="danger"

    local payload=$(cat <<EOF
{
    "attachments": [{
        "color": "$color",
        "title": "🚨 $severity Alert",
        "text": "$message",
        "fields": [
            {"title": "Host", "value": "$HOSTNAME", "short": true},
            {"title": "Environment", "value": "$ENVIRONMENT", "short": true},
            {"title": "Time", "value": "$(date '+%Y-%m-%d %H:%M:%S')", "short": false}
        ],
        "footer": "Log Monitoring System"
    }]
}
EOF
)

    curl -s -X POST -H 'Content-type: application/json' \
        --data "$payload" \
        "$WEBHOOK_URL" > /dev/null 2>&1
}

# ============================================================
# ALERT STATS
# ============================================================

show_alert_stats() {
    echo ""
    echo "═════════════════════════════════════"
    echo "  Alert Statistics"
    echo "═════════════════════════════════════"

    if [[ ! -f "$ALERT_LOG_FILE" ]]; then
        echo "No alerts yet"
        return
    fi

    local total=$(wc -l < "$ALERT_LOG_FILE")
    echo "Total alerts: $total"

    echo ""
    echo "By severity:"
    awk -F'[][]' '{print $4}' "$ALERT_LOG_FILE" | \
        sort | uniq -c | \
        awk '{printf "  %-10s: %3d\n", $2, $1}'

    echo ""
    echo "Today's alerts:"
    grep "^\\[$(date '+%Y-%m-%d')" "$ALERT_LOG_FILE" 2>/dev/null | wc -l | \
        awk '{print "  " $1 " alerts today"}'
}

clear_alert_cache() {
    rm -f "$ALERT_CACHE"/*
    echo "Alert cache cleared"
}

# ============================================================
# MAIN
# ============================================================

case "${1:-}" in
    --test)
        echo "Sending test alert..."
        send_alert "WARN" "Test alert from $(hostname) at $(date '+%Y-%m-%d %H:%M:%S')"
        ;;
    --stats)
        show_alert_stats
        ;;
    --clear-cache)
        clear_alert_cache
        ;;
    *)
        echo "Usage: $0 {--test|--stats|--clear-cache}"
        exit 1
        ;;
esac
