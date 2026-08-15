#!/bin/bash
# 05_fail2ban_setup.sh - Fail2ban Configuration
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "This script must be run as root"

SSH_PORT=${SSH_PORT:-2222}
log "=== Starting Fail2ban Configuration ==="

apt-get install -y fail2ban
mkdir -p /etc/fail2ban/jail.local.d

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = root@localhost
sendername = Fail2Ban
action = %(action_)s

[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 600
bantime = 3600

[sshd-ddos]
enabled = true
port = $SSH_PORT
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 10
findtime = 600
bantime = 3600

[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
action = %(action_)s
bantime = 604800
findtime = 86400
maxretry = 5
EOF

cat > /etc/fail2ban/filter.d/sshd-ddos.conf << 'EOF'
[Definition]
failregex = ^<HOST> \S+ sshd\[\d+\]: Invalid user \S+ from <HOST>
            ^<HOST> \S+ sshd\[\d+\]: Connection closed by <HOST>
            ^<HOST> \S+ sshd\[\d+\]: Received disconnect from <HOST>
ignoreregex =
EOF

touch /var/log/fail2ban.log
chmod 600 /var/log/fail2ban.log

systemctl enable fail2ban
systemctl start fail2ban
sleep 2

systemctl is-active --quiet fail2ban && log "Fail2ban is running" || error "Fail2ban failed"
fail2ban-client status

cat > /usr/local/bin/fail2ban-stats << 'EOF'
#!/bin/bash
echo "=== Fail2ban Status ==="
fail2ban-client status
echo ""
echo "=== SSH Jail Status ==="
fail2ban-client status sshd
echo ""
echo "=== Recent Bans ==="
tail -20 /var/log/fail2ban-bans.log 2>/dev/null || echo "No bans"
EOF
chmod +x /usr/local/bin/fail2ban-stats

log "=== Fail2ban Configuration Complete ==="
