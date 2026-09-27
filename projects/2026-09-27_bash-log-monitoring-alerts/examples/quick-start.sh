#!/bin/bash
# Quick start script for log monitor deployment
# Usage: sudo ./examples/quick-start.sh

set -euo pipefail

INSTALL_DIR="/opt/log-monitor"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=================================================="
echo "  Log Monitor Quick Start Installer"
echo "=================================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)"
   exit 1
fi

# Check dependencies
echo "[1/5] Checking dependencies..."
required_tools=("bash" "tail" "grep" "sed" "awk")
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool not found: $tool"
        exit 1
    fi
done

if ! command -v sendmail &> /dev/null && ! command -v mail &> /dev/null; then
    echo "Warning: Neither sendmail nor mail found. Email alerts may not work."
    echo "To install sendmail: apt-get install sendmail"
fi

echo "✓ Dependencies OK"
echo ""

# Create installation directory
echo "[2/5] Setting up installation directory..."
mkdir -p "$INSTALL_DIR"
cp -r "$PROJECT_DIR"/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/scripts"/*.sh
echo "✓ Installation directory created at $INSTALL_DIR"
echo ""

# Create state directory
echo "[3/5] Creating state directory..."
mkdir -p /var/log/log-monitor
chmod 755 /var/log/log-monitor
echo "✓ State directory created at /var/log/log-monitor"
echo ""

# Install systemd service
echo "[4/5] Installing systemd service..."
cp "$INSTALL_DIR/systemd/log-monitor.service" /etc/systemd/system/
systemctl daemon-reload
echo "✓ Systemd service installed"
echo ""

# Display next steps
echo "[5/5] Configuration"
echo "=================================================="
echo ""
echo "✓ Installation complete!"
echo ""
echo "Next steps:"
echo ""
echo "1. Edit the configuration:"
echo "   nano $INSTALL_DIR/config/log-monitor.conf"
echo ""
echo "2. Set your email for alerts:"
echo "   ALERT_EMAIL=\"your-email@example.com\""
echo ""
echo "3. Adjust log files to monitor (LOG_FILES):"
echo "   LOG_FILES=\"/var/log/syslog:/var/log/auth.log\""
echo ""
echo "4. Test the setup:"
echo "   bash $INSTALL_DIR/tests/run-tests.sh"
echo ""
echo "5. Start the monitoring service:"
echo "   systemctl start log-monitor"
echo "   systemctl enable log-monitor"
echo ""
echo "6. Check the status:"
echo "   systemctl status log-monitor"
echo ""
echo "7. View logs:"
echo "   journalctl -u log-monitor -f"
echo ""
echo "=================================================="
echo "For more information, see:"
echo "  $INSTALL_DIR/README.md"
echo "=================================================="
