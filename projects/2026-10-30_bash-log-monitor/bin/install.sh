#!/bin/bash

# Installation script for Log Monitor System
# Sets up necessary directories, permissions, and cron jobs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_PATH="${INSTALL_PATH:-/opt/log-monitor}"
CONFIG_PATH="${INSTALL_PATH}/config"
BIN_PATH="${INSTALL_PATH}/bin"
ALERT_PATH="${INSTALL_PATH}/alerts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        print_info "Run with: sudo $0"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    local missing=0

    # Check for required commands
    for cmd in mail grep sed awk; do
        if ! command -v "$cmd" &>/dev/null; then
            print_error "Required command not found: $cmd"
            missing=1
        fi
    done

    if [[ $missing -eq 1 ]]; then
        print_info "Install missing packages with:"
        print_info "  Ubuntu/Debian: sudo apt-get install -y mailutils grep sed gawk"
        print_info "  CentOS/RHEL: sudo yum install -y mailx grep sed gawk"
        exit 1
    fi

    print_success "All prerequisites met"
}

# Create installation directories
create_directories() {
    print_info "Creating installation directories..."

    mkdir -p "$BIN_PATH"
    mkdir -p "$CONFIG_PATH"
    mkdir -p "$ALERT_PATH"

    chmod 755 "$INSTALL_PATH"
    chmod 755 "$BIN_PATH"
    chmod 755 "$CONFIG_PATH"
    chmod 755 "$ALERT_PATH"

    print_success "Directories created at $INSTALL_PATH"
}

# Copy files to installation path
install_files() {
    print_info "Installing files..."

    # Copy scripts
    cp "$SCRIPT_DIR/bin/log-monitor.sh" "$BIN_PATH/"
    chmod 755 "$BIN_PATH/log-monitor.sh"
    print_success "Installed bin/log-monitor.sh"

    # Copy configuration files
    if [[ ! -f "$CONFIG_PATH/log-monitor.conf" ]]; then
        cp "$SCRIPT_DIR/config/log-monitor.conf" "$CONFIG_PATH/"
        chmod 644 "$CONFIG_PATH/log-monitor.conf"
        print_success "Installed config/log-monitor.conf"
    else
        print_info "Configuration file already exists, skipping"
    fi

    if [[ ! -f "$CONFIG_PATH/alert-rules.conf" ]]; then
        cp "$SCRIPT_DIR/config/alert-rules.conf" "$CONFIG_PATH/"
        chmod 644 "$CONFIG_PATH/alert-rules.conf"
        print_success "Installed config/alert-rules.conf"
    else
        print_info "Rules file already exists, skipping"
    fi
}

# Create systemd timer (optional)
create_systemd_timer() {
    print_info "Setting up systemd timer..."

    cat > /etc/systemd/system/log-monitor.service <<'EOF'
[Unit]
Description=Log Monitoring Alert System
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/log-monitor/bin/log-monitor.sh --config /opt/log-monitor/config/log-monitor.conf
StandardOutput=journal
StandardError=journal
SyslogIdentifier=log-monitor

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/log-monitor.timer <<'EOF'
[Unit]
Description=Log Monitor Timer
Requires=log-monitor.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    print_success "Systemd timer created"
    print_info "To enable the timer, run: sudo systemctl enable --now log-monitor.timer"
}

# Setup cron job
setup_cron() {
    print_info "Setting up cron job..."

    local cron_entry="*/5 * * * * $BIN_PATH/log-monitor.sh --config $CONFIG_PATH/log-monitor.conf >> $ALERT_PATH/log-monitor.log 2>&1"

    # Check if cron entry already exists
    if crontab -l 2>/dev/null | grep -q "log-monitor.sh"; then
        print_info "Cron job already exists, skipping"
        return
    fi

    # Add cron entry
    (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -

    print_success "Cron job installed (runs every 5 minutes)"
    print_info "To view cron jobs, run: crontab -l"
    print_info "To edit cron jobs, run: crontab -e"
}

# Verify installation
verify_installation() {
    print_info "Verifying installation..."

    local errors=0

    if [[ ! -f "$BIN_PATH/log-monitor.sh" ]]; then
        print_error "Binary not found at $BIN_PATH/log-monitor.sh"
        errors=$((errors + 1))
    fi

    if [[ ! -f "$CONFIG_PATH/log-monitor.conf" ]]; then
        print_error "Configuration not found at $CONFIG_PATH/log-monitor.conf"
        errors=$((errors + 1))
    fi

    if [[ ! -f "$CONFIG_PATH/alert-rules.conf" ]]; then
        print_error "Rules not found at $CONFIG_PATH/alert-rules.conf"
        errors=$((errors + 1))
    fi

    if [[ ! -d "$ALERT_PATH" ]]; then
        print_error "Alert directory not found at $ALERT_PATH"
        errors=$((errors + 1))
    fi

    if [[ $errors -eq 0 ]]; then
        print_success "Installation verified successfully"
        return 0
    else
        print_error "Installation verification failed"
        return 1
    fi
}

# Display configuration instructions
show_configuration_help() {
    cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Installation Path: /opt/log-monitor

📋 Next Steps:

1. Edit configuration:
   sudo nano /opt/log-monitor/config/log-monitor.conf

   Important settings:
   - LOGS_TO_MONITOR: Which logs to monitor
   - ALERT_EMAIL: Where to send alerts
   - ALERT_DIR: Where to store alerts

2. Review and customize alert rules:
   sudo nano /opt/log-monitor/config/alert-rules.conf

   Add patterns that should trigger alerts

3. Test the installation:
   sudo /opt/log-monitor/bin/log-monitor.sh --config /opt/log-monitor/config/log-monitor.conf

4. Enable monitoring:

   Option A - Using systemd timer:
   sudo systemctl enable --now log-monitor.timer
   sudo systemctl status log-monitor.timer

   Option B - Using cron (already installed):
   crontab -l    # View installed jobs
   crontab -e    # Edit cron jobs

5. Monitor logs:
   tail -f /opt/log-monitor/log-monitor.log
   tail -f /opt/log-monitor/alerts/*.alert

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Tips:

  • Email alerts require postfix or sendmail installed and running
  • Test email with: echo "Test" | mail -s "Test" your-email@example.com
  • Increase logging with: DEBUG_MODE=true in config
  • Use --dry-run flag to test without sending real alerts
  • Check email configuration: sudo systemctl status postfix

🔗 Documentation:
   README.md - Full documentation and examples

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# Main installation flow
main() {
    echo -e "${GREEN}"
    cat <<'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                 Log Monitor Installation Script                           ║
║                    DevOps Training Project v1.0                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    check_root
    check_prerequisites
    create_directories
    install_files
    create_systemd_timer
    setup_cron
    verify_installation
    show_configuration_help

    print_success "Installation complete!"
}

# Run installation
main "$@"
