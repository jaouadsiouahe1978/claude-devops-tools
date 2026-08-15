#!/bin/bash
# 01_initial_setup.sh - Initial Server Setup & Package Management
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

[[ $EUID -ne 0 ]] && error "This script must be run as root"

log "=== Starting Initial Server Setup ==="
log "Updating package lists..."
apt-get update
log "Upgrading packages..."
apt-get upgrade -y
log "Installing essential packages..."
apt-get install -y build-essential curl wget git vim nano htop net-tools netcat nmap traceroute \
    openssh-client openssh-server ssh-import-id ufw fail2ban auditd aide sudo lsof psmisc dnsutils

log "Installing security tools..."
apt-get install -y chkrootkit rkhunter tripwire lynis

log "Setting hostname..."
hostnamectl set-hostname "hardened-server"
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.0.0.1 hardened-server" >> /etc/hosts

log "Setting timezone to UTC..."
timedatectl set-timezone UTC

log "Enabling time sync..."
systemctl enable systemd-timesyncd
systemctl restart systemd-timesyncd

log "Enabling security services..."
systemctl enable ssh auditd fail2ban

log "Configuring kernel parameters..."
cat > /etc/sysctl.d/99-hardening.conf << 'EOF'
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
kernel.core_uses_pid = 1
fs.suid_dumpable = 0
fs.file-max = 2097152
EOF
sysctl -p /etc/sysctl.d/99-hardening.conf > /dev/null

log "=== Initial Setup Complete ==="
log "Next: Run 02_users_setup.sh"
