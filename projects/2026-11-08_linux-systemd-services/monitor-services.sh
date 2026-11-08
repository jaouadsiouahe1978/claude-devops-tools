#!/bin/bash

# Service Monitoring Dashboard
# Shows real-time status of services and their resource usage

REFRESH_INTERVAL=5
SERVICES=("simple-service.service" "health-check.timer")

clear

while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            SYSTEMD SERVICES MONITORING DASHBOARD              ║"
    echo "║                                                                ║"
    echo "║  Updated: $(date '+%Y-%m-%d %H:%M:%S')                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    # Services status
    echo "📋 SERVICE STATUS"
    echo "─────────────────────────────────────────────────────────────────"

    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            status="✓ ACTIVE"
            enabled="$(systemctl is-enabled "$service")"
        else
            status="✗ INACTIVE"
            enabled="disabled"
        fi

        echo "  $service"
        echo "    Status: $status | Enabled: $enabled"
        echo ""
    done

    echo "📊 RESOURCE USAGE"
    echo "─────────────────────────────────────────────────────────────────"

    # System resources
    memory=$(free -m | awk '/^Mem:/ {printf "%d/%d MB (%.1f%%)", $3, $2, $3/$2*100}')
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    load=$(uptime | awk -F'load average:' '{print $2}')

    echo "  Memory: $memory"
    echo "  CPU: $cpu user"
    echo "  Load Average: $load"
    echo ""

    echo "📝 RECENT LOGS (Last 5 entries)"
    echo "─────────────────────────────────────────────────────────────────"
    journalctl -u simple-service.service -n 5 --no-pager --output=short 2>/dev/null | while read line; do
        echo "  $line"
    done
    echo ""

    echo "⏱️  TIMERS"
    echo "─────────────────────────────────────────────────────────────────"
    systemctl list-timers health-check.timer --no-pager 2>/dev/null | tail -1 | awk '{print "  " $0}'
    echo ""

    echo "🔗 ENDPOINTS"
    echo "─────────────────────────────────────────────────────────────────"

    if command -v curl &> /dev/null; then
        for endpoint in "/health" "/metrics" "/ping"; do
            response=$(curl -s -w "%{http_code}" -m 2 "http://localhost:8888$endpoint" 2>/dev/null)
            http_code="${response: -3}"
            body="${response%???}"

            if [[ $http_code == "200" ]]; then
                echo "  ✓ GET localhost:8888$endpoint → HTTP $http_code"
            else
                echo "  ✗ GET localhost:8888$endpoint → HTTP $http_code (Service may not be running)"
            fi
        done
    fi
    echo ""

    echo "🛑 Press Ctrl+C to exit | Next refresh in ${REFRESH_INTERVAL}s..."
    sleep "$REFRESH_INTERVAL"
done
