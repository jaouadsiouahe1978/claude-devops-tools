#!/bin/bash

################################################################################
# UFW Setup Script - Configure Uncomplicated Firewall with Best Practices
# Purpose: Automate firewall configuration for secure Linux server
# Usage: sudo bash ufw-setup.sh [options]
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENABLE_LOGGING=true
ENABLE_RATE_LIMITING=true
SSH_PORT=22
HTTP_PORT=80
HTTPS_PORT=443

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

check_ubuntu() {
    if ! command -v ufw &> /dev/null; then
        log_info "UFW not found. Installing..."
        apt-get update
        apt-get install -y ufw
    fi
}

################################################################################
# Main Functions
################################################################################

install_ufw() {
    log_info "Installing UFW..."
    apt-get update > /dev/null 2>&1
    apt-get install -y ufw > /dev/null 2>&1
    log_success "UFW installed"
}

set_default_policies() {
    log_info "Setting default firewall policies..."

    # Deny all incoming by default
    ufw default deny incoming
    log_success "Set default policy: DENY incoming"

    # Allow all outgoing by default
    ufw default allow outgoing
    log_success "Set default policy: ALLOW outgoing"

    # IMPORTANT: Allow SSH BEFORE enabling firewall
    log_warning "Allowing SSH port $SSH_PORT (CRITICAL before enabling firewall)"
    ufw allow "$SSH_PORT/tcp"
    log_success "SSH port $SSH_PORT opened"
}

allow_http_https() {
    log_info "Opening HTTP and HTTPS ports..."
    ufw allow "$HTTP_PORT/tcp"
    log_success "HTTP port $HTTP_PORT opened"

    ufw allow "$HTTPS_PORT/tcp"
    log_success "HTTPS port $HTTPS_PORT opened"
}

enable_logging() {
    if [ "$ENABLE_LOGGING" = true ]; then
        log_info "Enabling UFW logging..."
        ufw logging on
        # Set logging level to medium (low, medium, high, full)
        ufw logging medium
        log_success "UFW logging enabled (level: medium)"
    fi
}

enable_rate_limiting() {
    if [ "$ENABLE_RATE_LIMITING" = true ]; then
        log_info "Enabling rate limiting for SSH..."
        # Replace allow rule with limit rule for SSH
        ufw delete allow "$SSH_PORT/tcp" 2>/dev/null || true
        ufw limit "$SSH_PORT/tcp"
        log_success "Rate limiting enabled for SSH (max 6 connections per 30s)"
    fi
}

additional_rules() {
    log_info "Adding additional security rules..."

    # Block common scanner ports
    log_info "Blocking common scanner ports..."
    ufw deny 111/udp  # NFS/RPC
    ufw deny 135/tcp  # Windows RPC
    ufw deny 139/tcp  # Windows NetBIOS
    ufw deny 445/tcp  # Windows SMB
    log_success "Scanner ports blocked"

    # Allow DNS (optional)
    log_info "Allowing DNS queries..."
    ufw allow out 53/tcp
    ufw allow out 53/udp
    log_success "DNS queries allowed (outgoing)"
}

enable_firewall() {
    log_info "Enabling UFW firewall..."

    # Show summary before enabling
    echo ""
    echo -e "${YELLOW}=== Firewall Rules Summary ===${NC}"
    ufw show added
    echo ""

    read -p "Do you want to enable the firewall now? (yes/no): " confirm

    if [[ "$confirm" == "yes" ]]; then
        # Enable firewall (non-interactive)
        echo "y" | ufw enable > /dev/null 2>&1
        log_success "UFW firewall ENABLED"
    else
        log_warning "Firewall not enabled. Run 'sudo ufw enable' when ready"
    fi
}

show_status() {
    log_info "Current firewall status:"
    echo ""
    ufw status verbose
    echo ""
}

reload_firewall() {
    log_info "Reloading firewall rules..."
    ufw reload
    log_success "Firewall reloaded"
}

################################################################################
# Main Execution
################################################################################

main() {
    log_info "Starting UFW Firewall Configuration"
    echo ""

    check_root
    check_ubuntu

    # Step 1: Install UFW
    install_ufw

    # Step 2: Set default policies
    set_default_policies

    # Step 3: Allow HTTP/HTTPS
    allow_http_https

    # Step 4: Enable logging
    enable_logging

    # Step 5: Enable rate limiting
    enable_rate_limiting

    # Step 6: Add additional security rules
    additional_rules

    # Step 7: Show status before enabling
    show_status

    # Step 8: Enable firewall
    enable_firewall

    echo ""
    log_success "UFW configuration completed!"
    echo ""
    echo -e "${BLUE}=== Quick Commands ===${NC}"
    echo "  View firewall status:     sudo ufw status numbered"
    echo "  Add a new rule:           sudo ufw allow <port>/tcp"
    echo "  Remove a rule:            sudo ufw delete allow <port>/tcp"
    echo "  View UFW logs:            sudo tail -f /var/log/ufw.log"
    echo "  Reload rules:             sudo ufw reload"
    echo "  Disable firewall:         sudo ufw disable"
    echo ""
}

# Run main function
main "$@"
