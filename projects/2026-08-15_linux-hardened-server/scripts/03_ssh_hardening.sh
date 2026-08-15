#!/bin/bash
# 03_ssh_hardening.sh - SSH Server Hardening
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "This script must be run as root"

SSH_PORT=${SSH_PORT:-2222}
log "=== Starting SSH Hardening (Port: $SSH_PORT) ==="

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d-%H%M%S)

cat > /etc/ssh/sshd_config << EOF
Port $SSH_PORT
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTH
LogLevel VERBOSE
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
PasswordAuthentication no
PermitEmptyPasswords no
HostbasedAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UsePAM yes
PermitRootLogin no
AllowUsers devops-admin sysadmin
AllowAgentForwarding no
AllowTcpForwarding no
PermitTunnel no
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 20
MaxAuthTries 3
MaxSessions 10
MaxStartups 10:30:60
StrictModes yes
IgnoreRhosts yes
PermitUserEnvironment no
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Banner /etc/issue.net
Subsystem sftp /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO
EOF

cat > /etc/issue.net << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║  Authorized Access Only - All Activity Monitored and Logged    ║
║  Unauthorized access to this system is forbidden and will be   ║
║  prosecuted by law. By accessing this system, you agree that   ║
║  your actions may be monitored and recorded.                   ║
╚═══════════════════════════════════════════════════════════════╝
EOF

sshd -t || error "SSH configuration validation failed"
ssh-keygen -A 2>/dev/null || true
chmod 700 /etc/ssh
chmod 600 /etc/ssh/sshd_config
chmod 644 /etc/ssh/ssh_host_*.pub
chmod 600 /etc/ssh/ssh_host_*_key
rm -f /etc/ssh/ssh_host_dsa_key* 2>/dev/null || true

systemctl restart sshd || error "SSH restart failed"
systemctl is-active --quiet sshd && log "SSH restarted successfully" || error "SSH not running"

log "=== SSH Hardening Complete ==="
