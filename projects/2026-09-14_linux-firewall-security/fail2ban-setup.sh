#!/bin/bash

################################################################################
# fail2ban Setup Script - Protect Against Brute Force Attacks
# Purpose: Install and configure fail2ban with custom jails
# Usage: sudo bash fail2ban-setup.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

################################################################################
# Main Functions
################################################################################

install_fail2ban() {
    log_info "Installing fail2ban..."
    apt-get update > /dev/null 2>&1
    apt-get install -y fail2ban > /dev/null 2>&1
    log_success "fail2ban installed"
}

backup_jail_conf() {
    log_info "Backing up original jail configuration..."
    if [ -f /etc/fail2ban/jail.conf ]; then
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak
        log_success "Backup created: /etc/fail2ban/jail.conf.bak"
    fi
}

create_jail_local() {
    log_info "Creating jail.local configuration..."

    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban duration (seconds): 10 minutes = 600 seconds
bantime = 600

# Find time window (seconds): 10 minutes = 600 seconds
findtime = 600

# Number of failures before ban
maxretry = 5

# Action to take (send email, just ban, etc)
action = %(action_mwl)s

# Enable/disable emails (requires postfix/mail)
# destemail = admin@example.com
# sendername = Fail2Ban
# action = %(action_mwl)s

# Whitelist trusted IPs (never ban these)
ignoreip = 127.0.0.1/8 ::1
# Add your office/home IP here:
# ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24

################################################################################
# SSH Jail - Protection against brute force SSH attacks
################################################################################
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 1800
findtime = 600

################################################################################
# Alternative SSH Jail for aggressive protection
################################################################################
[sshd-ddos]
enabled = true
port = ssh
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 10
bantime = 600
findtime = 600

################################################################################
# HTTP/HTTPS Protection against brute force login attempts
################################################################################
[apache-auth]
enabled = false
port = http,https
filter = apache-auth
logpath = /var/log/apache2/*error.log
maxretry = 5
bantime = 600

[apache-noscript]
enabled = false
port = http,https
filter = apache-noscript
logpath = /var/log/apache2/*error.log
maxretry = 6
bantime = 600

[apache-overLimit]
enabled = false
port = http,https
filter = apache-overLimit
logpath = /var/log/apache2/*error.log
bantime = 600
findtime = 600
maxretry = 5

################################################################################
# Nginx Jails
################################################################################
[nginx-http-auth]
enabled = false
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 5
bantime = 600

[nginx-limit-req]
enabled = false
port = http,https
filter = nginx-limit-req
logpath = /var/log/nginx/error.log
maxretry = 5
bantime = 600

################################################################################
# FTP/Postfix Protection
################################################################################
[vsftpd]
enabled = false
port = ftp,ftp-data,ftps,ftps-data
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 5
bantime = 1800

[postfix]
enabled = false
port = smtp,ssmtp,submission
filter = postfix
logpath = /var/log/mail.log
bantime = 600
maxretry = 5

################################################################################
# Dovecot (IMAP/POP3) Protection
################################################################################
[dovecot]
enabled = false
port = imap,pop3,imaps,pop3s,sieve
filter = dovecot
logpath = /var/log/mail.log
maxretry = 5
bantime = 600

################################################################################
# Custom Rule Examples (disabled by default)
################################################################################
# [my-custom-app]
# enabled = false
# port = 8080
# filter = my-custom-app
# logpath = /var/log/myapp.log
# maxretry = 3
# bantime = 300
EOF

    log_success "jail.local created with SSH protection enabled"
}

create_sshd_ddos_filter() {
    log_info "Creating sshd-ddos filter..."

    cat > /etc/fail2ban/filter.d/sshd-ddos.conf << 'EOF'
[Definition]
failregex = ^<HOST> .* sshd\[.*\]: (Invalid user|User|root|admin|test|ubuntu) .* from <HOST>
ignoreregex =
EOF

    log_success "sshd-ddos filter created"
}

enable_fail2ban() {
    log_info "Enabling fail2ban service..."

    systemctl enable fail2ban
    systemctl restart fail2ban

    log_success "fail2ban enabled and started"
}

show_status() {
    log_info "Current fail2ban status:"
    echo ""
    sleep 2  # Wait for service to fully start
    fail2ban-client status
    echo ""
}

show_jail_status() {
    log_info "SSH jail status:"
    echo ""
    fail2ban-client status sshd
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    log_info "Starting fail2ban Configuration"
    echo ""

    check_root

    # Step 1: Install fail2ban
    install_fail2ban

    # Step 2: Backup original config
    backup_jail_conf

    # Step 3: Create jail.local
    create_jail_local

    # Step 4: Create custom filters
    create_sshd_ddos_filter

    # Step 5: Enable fail2ban
    enable_fail2ban

    # Step 6: Show status
    show_status
    show_jail_status

    echo ""
    log_success "fail2ban configuration completed!"
    echo ""
    echo -e "${BLUE}=== Quick Commands ===${NC}"
    echo "  Check overall status:      sudo fail2ban-client status"
    echo "  Check SSH jail status:     sudo fail2ban-client status sshd"
    echo "  View banned IPs:           sudo fail2ban-client status sshd | grep Banned"
    echo "  Unban an IP:               sudo fail2ban-client set sshd unbanip <IP>"
    echo "  View fail2ban logs:        sudo tail -f /var/log/fail2ban.log"
    echo "  View SSH auth logs:        sudo tail -f /var/log/auth.log | grep 'Failed password'"
    echo "  Restart fail2ban:          sudo systemctl restart fail2ban"
    echo "  Test config:               sudo fail2ban-client -d"
    echo ""
    echo -e "${YELLOW}Note: You can edit /etc/fail2ban/jail.local to customize settings${NC}"
    echo ""
}

# Run main function
main "$@"
