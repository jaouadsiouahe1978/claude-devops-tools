#!/bin/bash

# Cron Jobs Setup for Log Monitoring System
# Installs automated tasks for monitoring and maintenance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRON_TEMP="/tmp/crontab_monitoring.tmp"

# ============================================================
# CRON JOBS DEFINITION
# ============================================================

setup_cron_jobs() {
    echo "Setting up cron jobs for log monitoring..."

    # Get current crontab (if exists)
    crontab -l 2>/dev/null > "$CRON_TEMP" || true

    # Define new jobs
    declare -A CRON_JOBS=(
        # Monitor check every 5 minutes
        ["*/5 * * * * ${SCRIPT_DIR}/scripts/log-monitor.sh --config ${SCRIPT_DIR}/config/monitoring.conf"]="Monitor check"

        # Daily log rotation at 2 AM
        ["0 2 * * * ${SCRIPT_DIR}/scripts/log-rotator.sh --full"]="Daily log rotation"

        # Daily report generation at 11 PM
        ["0 23 * * * ${SCRIPT_DIR}/scripts/report-generator.sh \$(date '+\\%Y-\\%m-\\%d') all"]="Daily report"

        # Weekly cleanup on Sunday at 3 AM
        ["0 3 * * 0 ${SCRIPT_DIR}/scripts/log-rotator.sh --cleanup"]="Weekly cleanup"

        # Hourly alert stats update
        ["0 * * * * ${SCRIPT_DIR}/scripts/alert-manager.sh --stats >> /tmp/alert-stats.log"]="Hourly alert stats"
    )

    # Add jobs if not already present
    for job in "${!CRON_JOBS[@]}"; do
        if ! grep -q "$(echo "$job" | cut -d' ' -f 6-)" "$CRON_TEMP" 2>/dev/null; then
            echo "Adding: ${CRON_JOBS[$job]}"
            echo "$job" >> "$CRON_TEMP"
        fi
    done

    # Install new crontab
    crontab "$CRON_TEMP"
    echo "✓ Cron jobs installed"

    # Show installed jobs
    echo ""
    echo "Current monitoring cron jobs:"
    crontab -l | grep "$SCRIPT_DIR"
}

remove_cron_jobs() {
    echo "Removing monitoring cron jobs..."

    crontab -l 2>/dev/null | grep -v "$SCRIPT_DIR" > "$CRON_TEMP" || true
    crontab "$CRON_TEMP"
    echo "✓ Cron jobs removed"
}

list_cron_jobs() {
    echo "Current monitoring cron jobs:"
    echo ""
    crontab -l 2>/dev/null | grep "$SCRIPT_DIR" || echo "No monitoring jobs found"
}

# ============================================================
# SYSTEMD SERVICE (Alternative to cron)
# ============================================================

create_systemd_service() {
    echo "Creating systemd service..."

    local service_file="/etc/systemd/system/log-monitor.service"
    local timer_file="/etc/systemd/system/log-monitor.timer"

    if [[ ! -w /etc/systemd/system/ ]]; then
        echo "ERROR: Need sudo to install systemd service"
        return 1
    fi

    # Service file
    sudo tee "$service_file" > /dev/null <<EOF
[Unit]
Description=Bash Log Monitoring & Alerting System
After=network.target

[Service]
Type=simple
ExecStart=${SCRIPT_DIR}/scripts/log-monitor.sh
ExecStop=/bin/kill -TERM \$MAINPID
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    echo "Service installed at: $service_file"
}

# ============================================================
# MAIN
# ============================================================

case "${1:-}" in
    --install)
        setup_cron_jobs
        ;;
    --remove)
        remove_cron_jobs
        ;;
    --list)
        list_cron_jobs
        ;;
    --service)
        create_systemd_service
        ;;
    *)
        echo "Usage: $0 {--install|--remove|--list|--service}"
        echo ""
        echo "Examples:"
        echo "  $0 --install    # Install cron jobs"
        echo "  $0 --list       # List installed jobs"
        echo "  $0 --remove     # Remove cron jobs"
        echo "  $0 --service    # Create systemd service"
        exit 1
        ;;
esac

rm -f "$CRON_TEMP"
