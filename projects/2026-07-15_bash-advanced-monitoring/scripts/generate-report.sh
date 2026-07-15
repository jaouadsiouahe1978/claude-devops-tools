#!/bin/bash

# generate-report.sh - Generate comprehensive monitoring reports
# Creates both text and HTML reports with metrics and analysis

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${PROJECT_ROOT}/config/monitor.conf"
LOGS_DIR="${PROJECT_ROOT}/logs"
DATA_DIR="${PROJECT_ROOT}/data"
REPORT_DIR="${LOGS_DIR}"

source "$CONFIG_FILE"
mkdir -p "$LOGS_DIR" "$DATA_DIR"

generate_text_report() {
    local report_file="${REPORT_DIR}/report-$(date +%Y%m%d-%H%M%S).txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    {
        echo "╔════════════════════════════════════════════════════╗"
        echo "║      SYSTEM MONITORING REPORT                      ║"
        echo "║      Generated: $timestamp"
        echo "╚════════════════════════════════════════════════════╝"
        echo ""

        echo "1. SYSTEM INFORMATION"
        echo "────────────────────────────────────────────────────"
        echo "Hostname:      $(hostname)"
        echo "OS:            $(lsb_release -ds 2>/dev/null || echo 'Unknown')"
        echo "Kernel:        $(uname -r)"
        echo "Uptime:        $(uptime -p)"
        echo ""

        echo "2. CURRENT RESOURCE USAGE"
        echo "────────────────────────────────────────────────────"
        local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        local ram=$(free | grep Mem | awk '{printf("%.1f", ($3 / $2) * 100)}')
        local disk=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
        local load=$(uptime | awk -F'load average:' '{print $2}')

        printf "CPU Usage:       %6.1f%%\n" "$cpu"
        printf "RAM Usage:       %6.1f%%\n" "$ram"
        printf "Disk Usage (/:  %6.1f%%\n" "$disk"
        echo "Load Average:    $load"
        echo ""

        echo "3. MEMORY BREAKDOWN"
        echo "────────────────────────────────────────────────────"
        free -h | tail -2
        echo ""

        echo "4. DISK USAGE BY FILESYSTEM"
        echo "────────────────────────────────────────────────────"
        df -h | tail -n +2
        echo ""

        echo "5. TOP PROCESSES (CPU)"
        echo "────────────────────────────────────────────────────"
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf("%-8s %6s  %s\n", $1, $3"%", $11)}'
        echo ""

        echo "6. TOP PROCESSES (RAM)"
        echo "────────────────────────────────────────────────────"
        ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf("%-8s %6s  %s\n", $1, $4"%", $11)}'
        echo ""

        echo "7. NETWORK INTERFACES"
        echo "────────────────────────────────────────────────────"
        ip -s link show | grep -A1 "^[0-9]:" | grep -v "^--$" | awk '/^[0-9]:/ {iface=$2} /RX|TX/ && iface {print iface $0; iface=""}'
        echo ""

        echo "8. OPEN CONNECTIONS"
        echo "────────────────────────────────────────────────────"
        echo "Listening ports: $(netstat -tuln 2>/dev/null | grep LISTEN | wc -l)"
        netstat -tuln 2>/dev/null | grep LISTEN | head -5 || echo "Could not retrieve listening ports"
        echo ""

        echo "9. SYSTEM ALERTS & WARNINGS"
        echo "────────────────────────────────────────────────────"
        if [[ -f "${DATA_DIR}/alert-history.log" ]]; then
            tail -10 "${DATA_DIR}/alert-history.log"
        else
            echo "No alerts recorded yet"
        fi
        echo ""

        echo "═══════════════════════════════════════════════════"
        echo "Report generated at: $timestamp"
        echo "═══════════════════════════════════════════════════"

    } > "$report_file"

    echo "✓ Text report generated: $report_file"
}

generate_html_report() {
    local report_file="${REPORT_DIR}/report-$(date +%Y%m%d-%H%M%S).html"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local ram=$(free | grep Mem | awk '{printf("%.1f", ($3 / $2) * 100)}')
    local disk=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)

    cat > "$report_file" <<'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>System Monitoring Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #333; border-bottom: 3px solid #0066cc; padding-bottom: 10px; }
        .metrics { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin: 20px 0; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric-label { font-weight: bold; color: #666; }
        .metric-value { font-size: 2em; color: #0066cc; margin-top: 10px; }
        .metric-unit { font-size: 0.5em; }
        .progress-bar { width: 100%; height: 20px; background-color: #e0e0e0; border-radius: 10px; overflow: hidden; margin-top: 10px; }
        .progress-fill { height: 100%; background-color: #4caf50; transition: width 0.3s; }
        .progress-fill.warning { background-color: #ff9800; }
        .progress-fill.critical { background-color: #f44336; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; background: white; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #0066cc; color: white; }
        tr:hover { background-color: #f9f9f9; }
        .footer { text-align: center; color: #999; margin-top: 40px; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>📊 System Monitoring Report</h1>
    <p><strong>Generated:</strong> [TIMESTAMP]</p>
    <p><strong>Hostname:</strong> [HOSTNAME]</p>

    <h2>Current Metrics</h2>
    <div class="metrics">
        <div class="metric-card">
            <div class="metric-label">CPU Usage</div>
            <div class="metric-value">[CPU]<span class="metric-unit">%</span></div>
            <div class="progress-bar">
                <div class="progress-fill [CPU_CLASS]" style="width: [CPU]%"></div>
            </div>
        </div>
        <div class="metric-card">
            <div class="metric-label">RAM Usage</div>
            <div class="metric-value">[RAM]<span class="metric-unit">%</span></div>
            <div class="progress-bar">
                <div class="progress-fill [RAM_CLASS]" style="width: [RAM]%"></div>
            </div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Disk Usage</div>
            <div class="metric-value">[DISK]<span class="metric-unit">%</span></div>
            <div class="progress-bar">
                <div class="progress-fill [DISK_CLASS]" style="width: [DISK]%"></div>
            </div>
        </div>
        <div class="metric-card">
            <div class="metric-label">System Uptime</div>
            <div class="metric-value">[UPTIME]</div>
        </div>
    </div>

    <h2>System Information</h2>
    <table>
        <tr><th>Property</th><th>Value</th></tr>
        <tr><td>OS</td><td>[OS]</td></tr>
        <tr><td>Kernel</td><td>[KERNEL]</td></tr>
        <tr><td>Processors</td><td>[PROCS]</td></tr>
    </table>

    <div class="footer">
        <p>System Monitoring Report | [TIMESTAMP]</p>
    </div>
</body>
</html>
HTMLEOF

    # Replace placeholders
    sed -i "s|\[TIMESTAMP\]|$timestamp|g" "$report_file"
    sed -i "s|\[HOSTNAME\]|$(hostname)|g" "$report_file"
    sed -i "s|\[CPU\]|${cpu}|g" "$report_file"
    sed -i "s|\[RAM\]|${ram}|g" "$report_file"
    sed -i "s|\[DISK\]|${disk}|g" "$report_file"
    sed -i "s|\[UPTIME\]|$(uptime -p)|g" "$report_file"
    sed -i "s|\[OS\]|$(lsb_release -ds 2>/dev/null || echo 'Unknown')|g" "$report_file"
    sed -i "s|\[KERNEL\]|$(uname -r)|g" "$report_file"
    sed -i "s|\[PROCS\]|$(nproc)|g" "$report_file"

    # Add alert classes based on thresholds
    local cpu_class="normal"
    local ram_class="normal"
    local disk_class="normal"

    (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l) )) && cpu_class="critical" || cpu_class="warning"
    (( $(echo "$ram > $RAM_THRESHOLD" | bc -l) )) && ram_class="critical" || ram_class="warning"
    (( $(echo "$disk > $DISK_THRESHOLD" | bc -l) )) && disk_class="critical" || disk_class="warning"

    sed -i "s|\[CPU_CLASS\]|${cpu_class}|g" "$report_file"
    sed -i "s|\[RAM_CLASS\]|${ram_class}|g" "$report_file"
    sed -i "s|\[DISK_CLASS\]|${disk_class}|g" "$report_file"

    echo "✓ HTML report generated: $report_file"
}

main() {
    case "${1:-both}" in
        text)
            generate_text_report
            ;;
        html)
            generate_html_report
            ;;
        both)
            generate_text_report
            generate_html_report
            ;;
        *)
            echo "Usage: $0 {text|html|both}"
            exit 1
            ;;
    esac
}

main "$@"
