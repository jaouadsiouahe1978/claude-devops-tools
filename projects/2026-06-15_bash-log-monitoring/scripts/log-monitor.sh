#!/bin/bash

# Bash Log Monitoring & Alerting System
# Main monitor script - tracks logs in real-time

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${1:-${SCRIPT_DIR}/config/monitoring.conf}"

# Source configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Initialize directories
mkdir -p "$(dirname "$ALERT_LOG_FILE")"
mkdir -p "$(dirname "$MONITOR_LOG_FILE")"
mkdir -p "$LOG_ARCHIVE_DIR"
mkdir -p "$REPORT_OUTPUT_DIR"

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$MONITOR_LOG_FILE"
}

debug() {
    [[ "$DEBUG_MODE" == "true" ]] && log "DEBUG" "$@"
}

alert() {
    local severity=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$severity] $message" >> "$ALERT_LOG_FILE"

    # Send notifications
    if [[ "$ENABLE_LOG" == "true" ]]; then
        log "ALERT" "[$severity] $message"
    fi

    # Send webhook
    if [[ "$ENABLE_WEBHOOK" == "true" ]] && [[ -n "$WEBHOOK_URL" ]]; then
        send_webhook "$severity" "$message"
    fi

    # Send email
    if [[ "$ENABLE_EMAIL" == "true" ]] && [[ -n "$ALERT_EMAIL" ]]; then
        send_email "$severity" "$message"
    fi
}

send_webhook() {
    local severity=$1
    local message=$2
    local payload=$(cat <<EOF
{
    "text": "🚨 Log Alert",
    "attachments": [{
        "color": "danger",
        "title": "$severity Alert",
        "text": "$message",
        "fields": [
            {"title": "Host", "value": "$HOSTNAME", "short": true},
            {"title": "Time", "value": "$(date '+%Y-%m-%d %H:%M:%S')", "short": true}
        ]
    }]
}
EOF
)

    curl -s -X POST -H 'Content-type: application/json' \
        --data "$payload" \
        --max-time "$WEBHOOK_TIMEOUT" \
        "$WEBHOOK_URL" > /dev/null 2>&1 || debug "Webhook send failed"
}

send_email() {
    local severity=$1
    local message=$2

    if command -v mail &> /dev/null; then
        echo "Alert: $message" | mail -s "[$severity] Log Alert on $HOSTNAME" "$ALERT_EMAIL" 2>/dev/null || true
    fi
}

# ============================================================
# LOG ANALYSIS FUNCTIONS
# ============================================================

count_patterns() {
    local logfile=$1
    local pattern=$2
    grep -c "$pattern" "$logfile" 2>/dev/null || echo 0
}

extract_matching_lines() {
    local logfile=$1
    local pattern=$2
    local count=$3

    grep "$pattern" "$logfile" 2>/dev/null | tail -n "$count"
}

analyze_log_file() {
    local logfile=$1

    if [[ ! -f "$logfile" ]]; then
        debug "Log file not found: $logfile"
        return
    fi

    debug "Analyzing: $logfile"

    # Count errors
    local error_count=$(count_patterns "$logfile" "$ERROR_PATTERN")
    debug "Found $error_count error(s) in $logfile"

    if [[ $error_count -gt $ALERT_THRESHOLD_ERROR ]]; then
        local recent_errors=$(extract_matching_lines "$logfile" "$ERROR_PATTERN" 3)
        alert "ERROR" "$logfile: $error_count errors detected. Recent: ${recent_errors:0:100}"
    fi

    # Count warnings
    local warn_count=$(count_patterns "$logfile" "$WARN_PATTERN")
    debug "Found $warn_count warning(s) in $logfile"

    if [[ $warn_count -gt $ALERT_THRESHOLD_WARN ]]; then
        alert "WARN" "$logfile: $warn_count warnings detected"
    fi
}

# ============================================================
# MAIN MONITORING LOOP
# ============================================================

monitor_loop() {
    log "INFO" "Starting log monitor (PID: $$)"
    log "INFO" "Monitoring files: ${LOG_PATHS[*]}"

    echo $$ > "$PID_FILE"

    while true; do
        for logfile in "${LOG_PATHS[@]}"; do
            analyze_log_file "$logfile"
        done

        sleep "$CHECK_INTERVAL"
    done
}

cleanup() {
    log "INFO" "Stopping log monitor"
    rm -f "$PID_FILE"
    exit 0
}

# ============================================================
# SIGNAL HANDLERS
# ============================================================

trap cleanup SIGTERM SIGINT

# ============================================================
# MAIN EXECUTION
# ============================================================

case "${1:-}" in
    --stop)
        if [[ -f "$PID_FILE" ]]; then
            kill "$(cat $PID_FILE)" 2>/dev/null && log "INFO" "Monitor stopped" || true
        fi
        ;;
    --status)
        if [[ -f "$PID_FILE" ]] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
            echo "✓ Monitor running (PID: $(cat $PID_FILE))"
            exit 0
        else
            echo "✗ Monitor not running"
            exit 1
        fi
        ;;
    --debug)
        DEBUG_MODE=true
        VERBOSE=true
        monitor_loop
        ;;
    *)
        [[ "$VERBOSE" == "true" ]] && log "INFO" "Configuration loaded: $CONFIG_FILE"
        monitor_loop
        ;;
esac
