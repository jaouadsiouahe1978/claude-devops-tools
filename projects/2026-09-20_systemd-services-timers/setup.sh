#!/bin/bash
# Setup script for Systemd Services & Timer Units project
# This script configures the example backup service and timer

set -e

echo "=== Systemd Services & Timer Units Setup ==="
echo "This script sets up a backup service with automated scheduling"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

# 1. Create dedicated user for backup service
echo "[1/5] Creating dedicated user 'backupuser'..."
if ! id "backupuser" &>/dev/null; then
    useradd -r -s /bin/bash -d /opt/backups backupuser
    echo "✓ User created"
else
    echo "✓ User already exists"
fi

# 2. Create directories and set permissions
echo "[2/5] Setting up directories..."
mkdir -p /opt/backups
chown backupuser:backupuser /opt/backups
chmod 750 /opt/backups
echo "✓ Directories ready"

# 3. Deploy scripts
echo "[3/5] Deploying scripts..."
cp backup.sh /opt/backups/backup.sh
cp health-check.sh /opt/backups/health-check.sh
chown backupuser:backupuser /opt/backups/*.sh
chmod 755 /opt/backups/*.sh
echo "✓ Scripts deployed"

# 4. Deploy systemd unit files
echo "[4/5] Deploying systemd units..."
cp backup.service /etc/systemd/system/backup.service
cp backup.timer /etc/systemd/system/backup.timer
cp app-dependent.service /etc/systemd/system/app-dependent.service
chmod 644 /etc/systemd/system/backup.*
chmod 644 /etc/systemd/system/app-dependent.service
echo "✓ Systemd units deployed"

# 5. Reload systemd and enable services
echo "[5/5] Configuring systemd..."
systemctl daemon-reload
systemctl enable backup.timer
echo "✓ Configuration complete"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Start the timer:"
echo "   sudo systemctl start backup.timer"
echo ""
echo "2. Check status:"
echo "   sudo systemctl status backup.timer"
echo "   sudo systemctl list-timers backup.timer"
echo ""
echo "3. View logs:"
echo "   sudo journalctl -u backup.service -f"
echo ""
echo "4. Run backup manually:"
echo "   sudo systemctl start backup.service"
echo ""
echo "5. Monitor all timers:"
echo "   systemctl list-timers --all"
echo ""
echo "Edit /etc/systemd/system/backup.timer to change schedule"
echo "After edits: sudo systemctl daemon-reload"
