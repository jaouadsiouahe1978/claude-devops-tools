#!/bin/bash
# 06_audit_setup.sh - Linux Audit Daemon Configuration
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "This script must be run as root"

log "=== Starting auditd Configuration ==="

apt-get install -y auditd audispd-plugins

cat > /etc/audit/rules.d/audit.rules << 'EOF'
-D
-b 8192
-f 1
-w /var/log/audit/ -k auditlog
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-w /etc/audit/audit.rules -p wa -k audit_rules_modifications
-w /etc/audit/audit.rules.d/ -p wa -k audit_rules_modifications
-w /etc/libaudit.conf -p wa -k audit_daemon_configuration
-w /etc/audisp/ -p wa -k audit_daemon_configuration
-w /sbin/auditctl -p x -k audit_tools
-w /sbin/auditd -p x -k audit_tools
-w /etc/sudoers -p wa -k sudoers_modifications
-w /etc/sudoers.d/ -p wa -k sudoers_modifications
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=-1 -k sudo_executions
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
-w /etc/ssh/sshd_config -p wa -k ssh_configuration
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins
-e 2
EOF

auditctl -R /etc/audit/rules.d/audit.rules

systemctl start auditd
systemctl enable auditd
sleep 2

systemctl is-active --quiet auditd && log "auditd is running" || error "auditd failed"

cat > /usr/local/bin/audit-stats << 'EOF'
#!/bin/bash
echo "=== Auditd Status ==="
systemctl status auditd --no-pager | head -5
echo ""
echo "=== Audit Rules Loaded ==="
auditctl -l | tail -1
echo ""
echo "=== Audit Log Size ==="
du -h /var/log/audit/
EOF
chmod +x /usr/local/bin/audit-stats

log "=== auditd Configuration Complete ==="
