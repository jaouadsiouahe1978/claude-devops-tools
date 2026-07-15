#!/bin/bash

# setup-cron.sh - Install cron jobs for automated monitoring
# Sets up scheduled tasks for regular monitoring and reporting

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Cron job definitions
CRON_JOBS=(
    "*/5 * * * * $SCRIPT_DIR/system-monitor.sh >> ${PROJECT_ROOT}/logs/monitor.log 2>&1 # Monitor every 5 minutes"
    "0 * * * * $SCRIPT_DIR/detect-anomalies.sh >> ${PROJECT_ROOT}/logs/monitor.log 2>&1 # Check anomalies hourly"
    "0 6 * * * $SCRIPT_DIR/generate-report.sh both >> ${PROJECT_ROOT}/logs/monitor.log 2>&1 # Daily report at 6 AM"
)

install_cron() {
    echo "Installing cron jobs for automated monitoring..."

    # Get current crontab (if exists)
    local current_cron=$(crontab -l 2>/dev/null || echo "")

    # Create temporary file for new crontab
    local temp_cron=$(mktemp)
    trap "rm -f $temp_cron" EXIT

    # Add existing crons
    if [[ -n "$current_cron" ]]; then
        echo "$current_cron" >> "$temp_cron"
    fi

    # Add new monitoring crons
    for job in "${CRON_JOBS[@]}"; do
        if ! grep -q "$(echo "$job" | cut -d'#' -f2)" "$temp_cron"; then
            echo "$job" >> "$temp_cron"
            echo "✓ Added: $(echo "$job" | cut -d'#' -f2-)"
        else
            echo "⊘ Already exists: $(echo "$job" | cut -d'#' -f2-)"
        fi
    done

    # Install new crontab
    crontab "$temp_cron"
    echo ""
    echo "Cron jobs installed successfully!"
    echo ""
    echo "Current cron schedule:"
    crontab -l | grep -E "monitor|detect|report" || echo "No monitoring crons found"
}

uninstall_cron() {
    echo "Removing monitoring cron jobs..."

    local current_cron=$(crontab -l 2>/dev/null || echo "")
    local temp_cron=$(mktemp)
    trap "rm -f $temp_cron" EXIT

    # Filter out monitoring jobs
    echo "$current_cron" | grep -v -E "monitor|detect|report" > "$temp_cron" || true

    # Install filtered crontab
    if [[ -s "$temp_cron" ]]; then
        crontab "$temp_cron"
        echo "✓ Monitoring cron jobs removed"
    else
        crontab -r 2>/dev/null || true
        echo "✓ All cron jobs removed"
    fi
}

list_cron() {
    echo "Current monitoring cron jobs:"
    echo "────────────────────────────────────────"
    crontab -l 2>/dev/null | grep -E "monitor|detect|report" || echo "No monitoring crons installed"
    echo ""
    echo "Full crontab:"
    echo "────────────────────────────────────────"
    crontab -l 2>/dev/null || echo "No crontab installed"
}

verify_installation() {
    echo "Verifying installation..."
    echo ""

    # Check if scripts exist and are executable
    for script in system-monitor.sh log-analyzer.sh detect-anomalies.sh generate-report.sh; do
        if [[ -x "$SCRIPT_DIR/$script" ]]; then
            echo "✓ $script is executable"
        else
            echo "✗ $script is NOT executable"
            chmod +x "$SCRIPT_DIR/$script"
        fi
    done

    echo ""
    echo "Testing scripts..."
    echo ""

    echo "Running system-monitor.sh..."
    "$SCRIPT_DIR/system-monitor.sh" 2>&1 | head -10
    echo ""

    echo "✓ Installation verified"
}

usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
  install   - Install monitoring cron jobs (default)
  uninstall - Remove monitoring cron jobs
  list      - List installed monitoring cron jobs
  verify    - Verify installation and test scripts
  help      - Show this help message

Examples:
  $0 install      # Install cron jobs
  $0 list         # Show installed jobs
  $0 uninstall    # Remove cron jobs

Cron jobs installed:
  - system-monitor.sh    Every 5 minutes
  - detect-anomalies.sh  Every hour
  - generate-report.sh   Daily at 6 AM
EOF
}

main() {
    case "${1:-install}" in
        install)
            install_cron
            verify_installation
            ;;
        uninstall)
            uninstall_cron
            ;;
        list)
            list_cron
            ;;
        verify)
            verify_installation
            ;;
        help)
            usage
            ;;
        *)
            echo "Unknown command: $1" >&2
            usage
            exit 1
            ;;
    esac
}

main "$@"
