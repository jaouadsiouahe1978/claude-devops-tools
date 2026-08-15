#!/bin/bash
# 04_firewall_setup.sh - UFW Firewall Configuration
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "This script must be run as root"

SSH_PORT=${SSH_PORT:-2222}
log "=== Starting Firewall Configuration (SSH port: $SSH_PORT) ==="

apt-get install -y ufw
echo "y" | ufw --force reset || true

log "Setting firewall policies..."
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

log "Allowing traffic..."
ufw allow in on lo
ufw allow out on lo
ufw allow "$SSH_PORT"/tcp comment 'Allow SSH'
ufw allow 80/tcp comment 'Allow HTTP'
ufw allow 443/tcp comment 'Allow HTTPS'
ufw allow out 53/tcp comment 'Allow DNS TCP'
ufw allow out 53/udp comment 'Allow DNS UDP'
ufw allow out 123/udp comment 'Allow NTP'
ufw limit "$SSH_PORT"/tcp comment 'Limit SSH rate'

ufw --force enable
log "Current UFW rules:"
ufw status numbered

mkdir -p /root/firewall-backup
ufw status > /root/firewall-backup/rules-$(date +%Y%m%d).txt

ufw logging low
log "=== Firewall Setup Complete ==="
