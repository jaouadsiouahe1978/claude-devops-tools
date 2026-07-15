#!/bin/bash

# detect-anomalies.sh - Detect system anomalies based on baselines
# Compares current metrics against baseline for deviation detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${PROJECT_ROOT}/config/monitor.conf"
DATA_DIR="${PROJECT_ROOT}/data"
BASELINE_FILE="${DATA_DIR}/baseline-metrics.txt"
ALERT_HISTORY="${DATA_DIR}/alert-history.log"

source "$CONFIG_FILE"
mkdir -p "$DATA_DIR"

log_alert() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$ALERT_HISTORY"
}

get_metrics() {
    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local ram=$(free | grep Mem | awk '{printf("%.1f", ($3 / $2) * 100)}')
    local disk=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    local load=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)

    cat <<EOF
cpu=$cpu
ram=$ram
disk=$disk
load=$load
timestamp=$(date '+%s')
EOF
}

create_baseline() {
    echo "Creating baseline metrics..."
    get_metrics > "$BASELINE_FILE"
    log_alert "INFO" "Baseline created"
}

load_baseline() {
    if [[ ! -f "$BASELINE_FILE" ]]; then
        create_baseline
        return 1
    fi
    source "$BASELINE_FILE"
}

detect_deviation() {
    local metric_name="$1"
    local current="$2"
    local baseline="$3"
    local threshold="$4"

    # Calculate percentage deviation
    local deviation=$(echo "scale=2; (($current - $baseline) / $baseline) * 100" | bc 2>/dev/null || echo "0")

    # Check if deviation exceeds threshold
    if (( $(echo "$deviation > $threshold" | bc -l) )); then
        return 0  # Anomaly detected
    fi
    return 1
}

check_anomalies() {
    echo "========================================"
    echo "ANOMALY DETECTION - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"

    # Load baseline
    local baseline_cpu=0 baseline_ram=0 baseline_disk=0 baseline_load=0
    if load_baseline; then
        baseline_cpu=$cpu
        baseline_ram=$ram
        baseline_disk=$disk
        baseline_load=$load
    else
        echo "Baseline not available - using first run as baseline"
        return
    fi

    # Get current metrics
    local current_cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local current_ram=$(free | grep Mem | awk '{printf("%.1f", ($3 / $2) * 100)}')
    local current_disk=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    local current_load=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)

    echo ""
    echo "Baseline vs Current metrics:"
    printf "%-12s | %-10s | %-10s | %-10s\n" "Metric" "Baseline" "Current" "Deviation"
    echo "-------------|------------|------------|------------"
    printf "CPU%%        | %-10.1f | %-10.1f | " "$baseline_cpu" "$current_cpu"
    echo "$(echo "scale=1; (($current_cpu - $baseline_cpu) / $baseline_cpu) * 100" | bc 2>/dev/null || echo "N/A")%"
    printf "RAM%%        | %-10.1f | %-10.1f | " "$baseline_ram" "$current_ram"
    echo "$(echo "scale=1; (($current_ram - $baseline_ram) / $baseline_ram) * 100" | bc 2>/dev/null || echo "N/A")%"
    printf "DISK%%       | %-10.1f | %-10.1f | " "$baseline_disk" "$current_disk"
    echo "$(echo "scale=1; (($current_disk - $baseline_disk) / $baseline_disk) * 100" | bc 2>/dev/null || echo "N/A")%"

    echo ""
    echo "Anomaly Detection (threshold: ${ANOMALY_THRESHOLD}%):"
    echo "----------------------------------------"

    local anomalies=0

    # Check CPU deviation
    if detect_deviation "CPU" "$current_cpu" "$baseline_cpu" "$ANOMALY_THRESHOLD"; then
        local cpu_dev=$(echo "scale=1; (($current_cpu - $baseline_cpu) / $baseline_cpu) * 100" | bc)
        log_alert "ANOMALY" "CPU spike detected: ${cpu_dev}% increase from baseline"
        ((anomalies++))
    fi

    # Check RAM deviation
    if detect_deviation "RAM" "$current_ram" "$baseline_ram" "$ANOMALY_THRESHOLD"; then
        local ram_dev=$(echo "scale=1; (($current_ram - $baseline_ram) / $baseline_ram) * 100" | bc)
        log_alert "ANOMALY" "RAM spike detected: ${ram_dev}% increase from baseline"
        ((anomalies++))
    fi

    # Check DISK deviation
    if detect_deviation "DISK" "$current_disk" "$baseline_disk" "$ANOMALY_THRESHOLD"; then
        local disk_dev=$(echo "scale=1; (($current_disk - $baseline_disk) / $baseline_disk) * 100" | bc)
        log_alert "ANOMALY" "DISK increase detected: ${disk_dev}% growth from baseline"
        ((anomalies++))
    fi

    if [[ $anomalies -eq 0 ]]; then
        echo "✓ No anomalies detected - system operating within normal parameters"
    else
        echo "✗ $anomalies anomaly/anomalies detected - review logs for details"
    fi

    echo ""
    echo "Hard thresholds:"
    echo "CPU > ${CPU_THRESHOLD}%: $(( $(echo "$current_cpu > $CPU_THRESHOLD" | bc -l) )) (1=exceeded, 0=ok)"
    echo "RAM > ${RAM_THRESHOLD}%: $(( $(echo "$current_ram > $RAM_THRESHOLD" | bc -l) )) (1=exceeded, 0=ok)"
    echo "DISK > ${DISK_THRESHOLD}%: $(( $(echo "$current_disk > $DISK_THRESHOLD" | bc -l) )) (1=exceeded, 0=ok)"
}

reset_baseline() {
    echo "Resetting baseline metrics..."
    rm -f "$BASELINE_FILE"
    create_baseline
    echo "Baseline reset complete"
}

main() {
    case "${1:-check}" in
        check)
            check_anomalies
            ;;
        baseline)
            create_baseline
            ;;
        reset)
            reset_baseline
            ;;
        *)
            echo "Usage: $0 {check|baseline|reset}"
            echo "  check   - Check for anomalies (default)"
            echo "  baseline - Create/update baseline metrics"
            echo "  reset   - Reset baseline to current state"
            exit 1
            ;;
    esac
}

main "$@"
