#!/bin/bash

# system-monitor.sh - Real-time system resource monitoring
# Monitors CPU, RAM, Disk usage and Load average

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${PROJECT_ROOT}/config/monitor.conf"
LOG_FILE="${PROJECT_ROOT}/logs/monitor.log"

# Source configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

get_cpu_usage() {
    # Calculate CPU usage using /proc/stat
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "$cpu_usage"
}

get_ram_usage() {
    # Get RAM usage percentage
    local ram_usage=$(free | grep Mem | awk '{printf("%.1f", ($3 / $2) * 100)}')
    echo "$ram_usage"
}

get_disk_usage() {
    # Get root filesystem disk usage
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    echo "$disk_usage"
}

get_load_average() {
    # Get 1-minute load average
    local load=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
    echo "$load"
}

display_metrics() {
    local cpu=$(get_cpu_usage)
    local ram=$(get_ram_usage)
    local disk=$(get_disk_usage)
    local load=$(get_load_average)

    echo "============================================"
    echo "  SYSTEM METRICS - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "============================================"
    printf "CPU Usage:        %6.1f%%\n" "$cpu"
    printf "RAM Usage:        %6.1f%%\n" "$ram"
    printf "DISK Usage (/:    %6.1f%%\n" "$disk"
    printf "Load Average:     %s\n" "$load"
    echo "============================================"

    # Log metrics
    log_message "INFO" "CPU:$cpu% RAM:$ram% DISK:$disk% LOAD:$load"
}

check_thresholds() {
    local cpu=$(get_cpu_usage)
    local ram=$(get_ram_usage)
    local disk=$(get_disk_usage)

    if (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l) )); then
        log_message "WARN" "High CPU usage detected: $cpu% (threshold: $CPU_THRESHOLD%)"
    fi

    if (( $(echo "$ram > $RAM_THRESHOLD" | bc -l) )); then
        log_message "WARN" "High RAM usage detected: $ram% (threshold: $RAM_THRESHOLD%)"
    fi

    if (( $(echo "$disk > $DISK_THRESHOLD" | bc -l) )); then
        log_message "ALERT" "Critical disk usage: $disk% (threshold: $DISK_THRESHOLD%)"
    fi
}

show_top_processes() {
    echo ""
    echo "Top 5 CPU-consuming processes:"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf("%-8s %-6s %s\n", $1, $3"%", $11)}'

    echo ""
    echo "Top 5 RAM-consuming processes:"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf("%-8s %-6s %s\n", $1, $4"%", $11)}'
}

main() {
    display_metrics
    check_thresholds
    show_top_processes
}

main "$@"
