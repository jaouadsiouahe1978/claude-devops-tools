#!/bin/bash
###############################################################################
# Backup Automation Installation Script
# Sets up the backup system on the host
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Backup Automation Installation${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] This script must be run as root${NC}"
    echo "Try: sudo $0"
    exit 1
fi

# Copy scripts to /usr/local/bin
echo -e "${BLUE}[1/4] Installing scripts...${NC}"
cp "${SCRIPT_DIR}/backup.sh" /usr/local/bin/
cp "${SCRIPT_DIR}/backup-rotate.sh" /usr/local/bin/
cp "${SCRIPT_DIR}/backup-verify.sh" /usr/local/bin/
cp "${SCRIPT_DIR}/backup-monitoring.sh" /usr/local/bin/
cp "${SCRIPT_DIR}/backup-restore.sh" /usr/local/bin/
cp "${SCRIPT_DIR}/backup-config.sh" /usr/local/bin/

chmod +x /usr/local/bin/backup*.sh

echo -e "${GREEN}✓ Scripts installed${NC}"
echo ""

# Create directories
echo -e "${BLUE}[2/4] Creating directories...${NC}"
mkdir -p /var/backups/custom-backups
mkdir -p /var/log/backup
chmod 700 /var/backups/custom-backups
chmod 755 /var/log/backup

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Create initial log file
echo -e "${BLUE}[3/4] Initializing logs...${NC}"
touch /var/log/backup/backup-$(date +%Y-%m).log
touch /var/log/backup/cron.log
chmod 644 /var/log/backup/*.log

echo -e "${GREEN}✓ Log files created${NC}"
echo ""

# Install cron jobs (optional)
echo -e "${BLUE}[4/4] Cron configuration${NC}"
echo ""
echo "To add cron jobs, run:"
echo "  sudo crontab -e"
echo ""
echo "Copy and paste from: ${SCRIPT_DIR}/crontab.example"
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit /usr/local/bin/backup-config.sh"
echo "  2. Run: sudo /usr/local/bin/backup.sh (test)"
echo "  3. Run: sudo /usr/local/bin/backup-verify.sh latest"
echo "  4. Add cron jobs: sudo crontab -e"
echo ""
echo "Documentation:"
echo "  - README.md: Overview and concepts"
echo "  - crontab.example: Cron scheduling examples"
echo ""
