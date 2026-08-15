#!/bin/bash
# 02_users_setup.sh - User and Group Management
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "This script must be run as root"

log "=== Starting User & Group Setup ==="

# Create admin group
! getent group admin > /dev/null && groupadd admin && log "Admin group created"
! getent group sudo > /dev/null && groupadd sudo && log "Sudo group created"

# Create users
create_user() {
    if ! id "$1" &>/dev/null; then
        useradd -m -s /bin/bash -c "$2" "$1"
        mkdir -p /home/"$1"/.ssh && chmod 700 /home/"$1"/.ssh
        chown -R "$1":"$1" /home/"$1"
        log "User $1 created"
    fi
}

create_user "devops-admin" "DevOps Administrator"
create_user "sysadmin" "System Administrator"
create_user "developer" "Developer User"

usermod -aG sudo devops-admin sysadmin
usermod -aG admin devops-admin sysadmin

log "Locking root account..."
passwd -l root

cat > /etc/sudoers.d/01-secure << 'EOF'
Defaults use_pty,logfile="/var/log/sudo.log",log_input,log_output,requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults passwd_timeout=1,passwd_tries=3,log_host,log_user
%admin ALL=(ALL) ALL
%sudo ALL=(ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/01-secure
visudo -c -f /etc/sudoers.d/01-secure > /dev/null 2>&1

log "=== User & Group Setup Complete ==="
