#!/bin/bash

################################################################################
# Security Test Script - Verify Firewall and fail2ban Configuration
# Purpose: Test firewall rules and fail2ban protection
# Usage: sudo bash test-security.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASS_COUNT++))
}

log_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAIL_COUNT++))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_header() {
    echo ""
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} $1"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root${NC}"
        exit 1
    fi
}

################################################################################
# UFW Tests
################################################################################

test_ufw_installed() {
    log_header "Testing UFW Installation"

    if command -v ufw &> /dev/null; then
        log_success "UFW is installed"
        local version=$(ufw version 2>/dev/null | head -1)
        echo "    Version: $version"
    else
        log_fail "UFW is not installed"
    fi
}

test_ufw_status() {
    log_header "Testing UFW Status"

    if systemctl is-active --quiet ufw; then
        log_success "UFW service is active"
    else
        log_warning "UFW service is not active (might be disabled)"
    fi

    local status=$(ufw status | head -1)
    if [[ "$status" == *"active"* ]]; then
        log_success "UFW firewall is ENABLED"
    else
        log_warning "UFW firewall is DISABLED"
    fi
}

test_ufw_rules() {
    log_header "Testing UFW Rules"

    echo -e "${BLUE}Current UFW Rules:${NC}"
    ufw status numbered || true
    echo ""

    # Check SSH rule
    if ufw status | grep -q "22.*ALLOW\|22.*LIMIT"; then
        log_success "SSH port 22 is allowed/limited"
    else
        log_fail "SSH port 22 is NOT properly allowed"
    fi

    # Check HTTP rule
    if ufw status | grep -q "80.*ALLOW"; then
        log_success "HTTP port 80 is allowed"
    else
        log_warning "HTTP port 80 is not explicitly allowed"
    fi

    # Check HTTPS rule
    if ufw status | grep -q "443.*ALLOW"; then
        log_success "HTTPS port 443 is allowed"
    else
        log_warning "HTTPS port 443 is not explicitly allowed"
    fi

    # Check default policies
    if ufw status verbose | grep -q "Default: deny \(incoming\|in\)"; then
        log_success "Default incoming policy is DENY"
    else
        log_fail "Default incoming policy is NOT DENY"
    fi

    if ufw status verbose | grep -q "Default: allow \(outgoing\|out\)"; then
        log_success "Default outgoing policy is ALLOW"
    else
        log_fail "Default outgoing policy is NOT ALLOW"
    fi
}

test_port_connectivity() {
    log_header "Testing Port Connectivity"

    local host="127.0.0.1"

    # Test SSH
    if timeout 2 bash -c "echo >/dev/tcp/$host/22" 2>/dev/null; then
        log_success "SSH port 22 is reachable"
    else
        log_warning "SSH port 22 is not reachable"
    fi

    # Test HTTP
    if timeout 2 bash -c "echo >/dev/tcp/$host/80" 2>/dev/null; then
        log_success "HTTP port 80 is reachable"
    else
        log_warning "HTTP port 80 is not reachable (web server might not be running)"
    fi

    # Test HTTPS
    if timeout 2 bash -c "echo >/dev/tcp/$host/443" 2>/dev/null; then
        log_success "HTTPS port 443 is reachable"
    else
        log_warning "HTTPS port 443 is not reachable (web server might not be running)"
    fi

    # Test blocked port (should fail)
    if timeout 2 bash -c "echo >/dev/tcp/$host/23" 2>/dev/null; then
        log_fail "Telnet port 23 should be blocked but is reachable!"
    else
        log_success "Telnet port 23 is properly blocked"
    fi
}

test_ufw_logging() {
    log_header "Testing UFW Logging"

    if ufw status verbose | grep -q "Logging: on"; then
        log_success "UFW logging is ENABLED"
        local log_level=$(ufw status verbose | grep "Logging:" | awk '{print $NF}')
        echo "    Log level: $log_level"
    else
        log_warning "UFW logging is disabled"
    fi

    if [ -f /var/log/ufw.log ]; then
        log_success "UFW log file exists: /var/log/ufw.log"
        local log_lines=$(wc -l < /var/log/ufw.log)
        echo "    Log entries: $log_lines"
    else
        log_warning "UFW log file not found"
    fi
}

################################################################################
# fail2ban Tests
################################################################################

test_fail2ban_installed() {
    log_header "Testing fail2ban Installation"

    if command -v fail2ban-client &> /dev/null; then
        log_success "fail2ban is installed"
        local version=$(fail2ban-client --version | head -1)
        echo "    Version: $version"
    else
        log_fail "fail2ban is not installed"
    fi
}

test_fail2ban_status() {
    log_header "Testing fail2ban Status"

    if systemctl is-active --quiet fail2ban; then
        log_success "fail2ban service is RUNNING"
    else
        log_fail "fail2ban service is NOT running"
    fi
}

test_fail2ban_jails() {
    log_header "Testing fail2ban Jails"

    echo -e "${BLUE}Active Jails:${NC}"
    fail2ban-client status | grep "Jail list:"
    echo ""

    # Check if sshd jail exists
    if fail2ban-client status | grep -q "sshd"; then
        log_success "SSH jail (sshd) is active"

        # Get jail status
        local ssh_status=$(fail2ban-client status sshd 2>/dev/null || echo "")
        if [ -n "$ssh_status" ]; then
            echo "    $ssh_status" | head -3
        fi
    else
        log_fail "SSH jail (sshd) is not active"
    fi
}

test_fail2ban_config() {
    log_header "Testing fail2ban Configuration"

    if [ -f /etc/fail2ban/jail.local ]; then
        log_success "Custom jail.local file exists"

        # Check for sshd jail configuration
        if grep -q "^\[sshd\]" /etc/fail2ban/jail.local; then
            log_success "SSH jail is configured in jail.local"

            local maxretry=$(grep -A 5 "^\[sshd\]" /etc/fail2ban/jail.local | grep "maxretry" | head -1 | awk -F= '{print $2}' | xargs)
            echo "    Max retries: $maxretry"
        fi
    else
        log_warning "jail.local not found (using defaults)"
    fi
}

test_fail2ban_logs() {
    log_header "Testing fail2ban Logs"

    if [ -f /var/log/fail2ban.log ]; then
        log_success "fail2ban log file exists"
        local log_lines=$(wc -l < /var/log/fail2ban.log)
        echo "    Total log entries: $log_lines"

        # Show recent activity
        echo ""
        echo -e "${BLUE}Recent activity (last 5 lines):${NC}"
        tail -5 /var/log/fail2ban.log | sed 's/^/    /'
    else
        log_warning "fail2ban log file not found"
    fi
}

test_banned_ips() {
    log_header "Testing Banned IPs"

    local banned_count=$(fail2ban-client status sshd 2>/dev/null | grep "Banned IP" | awk '{print $NF}' || echo "0")

    if [ "$banned_count" -eq 0 ]; then
        log_success "No IPs currently banned (system is clean)"
    else
        log_warning "Found $banned_count banned IP(s)"
        echo "    Banned IPs:"
        fail2ban-client status sshd | grep -E "^\s+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed 's/^/      /'
    fi
}

################################################################################
# Security Summary Tests
################################################################################

test_security_summary() {
    log_header "Security Posture Summary"

    echo -e "${BLUE}Server Security Checklist:${NC}"
    echo ""

    # Check if services are running
    if systemctl is-active --quiet ufw; then
        echo "  ${GREEN}✓${NC} UFW Firewall is active"
    else
        echo "  ${RED}✗${NC} UFW Firewall is NOT active"
    fi

    if systemctl is-active --quiet fail2ban; then
        echo "  ${GREEN}✓${NC} fail2ban is active"
    else
        echo "  ${RED}✗${NC} fail2ban is NOT active"
    fi

    # Check if SSH is protected
    if ufw status | grep -q "22"; then
        echo "  ${GREEN}✓${NC} SSH port 22 has firewall rules"
    else
        echo "  ${RED}✗${NC} SSH port 22 does NOT have firewall rules"
    fi

    # Check if logging is enabled
    if ufw status verbose | grep -q "Logging: on"; then
        echo "  ${GREEN}✓${NC} UFW logging is enabled"
    else
        echo "  ${YELLOW}!${NC} UFW logging is disabled"
    fi

    # Check auth.log for failed attempts
    if [ -f /var/log/auth.log ]; then
        local failed_attempts=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l || echo "0")
        echo "  ${YELLOW}!${NC} Failed login attempts: $failed_attempts"
    fi
}

################################################################################
# Generate Report
################################################################################

generate_report() {
    log_header "Test Report Summary"

    local total=$((PASS_COUNT + FAIL_COUNT))
    local percentage=0
    if [ $total -gt 0 ]; then
        percentage=$((PASS_COUNT * 100 / total))
    fi

    echo "Tests Passed:  ${GREEN}$PASS_COUNT${NC}"
    echo "Tests Failed:  ${RED}$FAIL_COUNT${NC}"
    echo "Total Tests:   $total"
    echo "Success Rate:  ${BLUE}${percentage}%${NC}"
    echo ""

    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed! Your firewall is properly configured.${NC}"
    else
        echo -e "${YELLOW}! Some tests failed. Please review the configuration above.${NC}"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    check_root

    echo -e "${MAGENTA}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║        Linux Firewall Security - Configuration Test            ║
║                                                                ║
║  This script tests:                                           ║
║  - UFW installation and configuration                         ║
║  - Firewall rules and policies                                ║
║  - Port connectivity and blocking                             ║
║  - fail2ban installation and jails                            ║
║  - Protection against brute force attacks                     ║
║  - Logging and monitoring                                     ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Run UFW tests
    test_ufw_installed
    test_ufw_status
    test_ufw_rules
    test_port_connectivity
    test_ufw_logging

    # Run fail2ban tests
    test_fail2ban_installed
    test_fail2ban_status
    test_fail2ban_jails
    test_fail2ban_config
    test_fail2ban_logs
    test_banned_ips

    # Security summary
    test_security_summary

    # Generate report
    generate_report
}

# Run main function
main "$@"
