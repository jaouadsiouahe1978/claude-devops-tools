#!/bin/bash

################################################################################
# Firewall Monitoring Script - Real-time Security Monitoring
# Purpose: Monitor UFW and fail2ban activity in real-time
# Usage: sudo bash monitor-firewall.sh [watch|tail|dashboard]
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# Helper Functions
################################################################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root${NC}"
        exit 1
    fi
}

clear_screen() {
    clear
}

print_header() {
    echo -e "${MAGENTA}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║           Firewall Security - Real-time Monitoring             ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_timestamp() {
    echo -e "${CYAN}Last updated: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
}

################################################################################
# UFW Monitoring
################################################################################

show_ufw_status() {
    echo -e "${BLUE}═══ UFW FIREWALL STATUS ═══${NC}"

    if systemctl is-active --quiet ufw; then
        echo -e "${GREEN}✓ UFW is ACTIVE${NC}"
    else
        echo -e "${RED}✗ UFW is INACTIVE${NC}"
    fi

    echo ""
    ufw status | head -20
    echo ""
}

show_ufw_rules() {
    echo -e "${BLUE}═══ ACTIVE FIREWALL RULES ═══${NC}"

    echo -e "${CYAN}Numbered rules:${NC}"
    ufw show added | head -15
    echo ""
}

show_ufw_logs() {
    echo -e "${BLUE}═══ RECENT UFW LOG ENTRIES ═══${NC}"

    if [ -f /var/log/ufw.log ]; then
        echo -e "${CYAN}Last 10 blocked connections:${NC}"
        grep BLOCK /var/log/ufw.log 2>/dev/null | tail -10 | sed 's/^/  /'
        echo ""
    fi
}

################################################################################
# fail2ban Monitoring
################################################################################

show_fail2ban_status() {
    echo -e "${BLUE}═══ FAIL2BAN STATUS ═══${NC}"

    if systemctl is-active --quiet fail2ban; then
        echo -e "${GREEN}✓ fail2ban is RUNNING${NC}"
    else
        echo -e "${RED}✗ fail2ban is NOT running${NC}"
    fi

    echo ""
    fail2ban-client status 2>/dev/null
    echo ""
}

show_ssh_jail_status() {
    echo -e "${BLUE}═══ SSH JAIL PROTECTION ═══${NC}"

    fail2ban-client status sshd 2>/dev/null || echo "SSH jail not active"
    echo ""
}

show_banned_ips() {
    echo -e "${BLUE}═══ CURRENTLY BANNED IPs ═══${NC}"

    local banned=$(fail2ban-client status sshd 2>/dev/null | grep "Banned IP" | awk '{print $NF}')

    if [ "$banned" -eq 0 ] 2>/dev/null; then
        echo -e "${GREEN}No banned IPs (system is clean)${NC}"
    else
        echo -e "${YELLOW}$banned IP(s) are currently banned${NC}"
        echo ""
        echo -e "${CYAN}Banned IPs:${NC}"
        fail2ban-client status sshd 2>/dev/null | grep -E "^\s+[0-9]{1,3}\." | sed 's/^/  /'
    fi
    echo ""
}

################################################################################
# SSH Authentication Monitoring
################################################################################

show_failed_logins() {
    echo -e "${BLUE}═══ SSH FAILED LOGIN ATTEMPTS ═══${NC}"

    if [ -f /var/log/auth.log ]; then
        local failed_count=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)

        if [ "$failed_count" -gt 0 ]; then
            echo -e "${YELLOW}Total failed attempts: $failed_count${NC}"
            echo ""
            echo -e "${CYAN}Last 5 failed login attempts:${NC}"
            grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 | sed 's/^/  /'
        else
            echo -e "${GREEN}No failed login attempts${NC}"
        fi
    fi
    echo ""
}

show_successful_logins() {
    echo -e "${BLUE}═══ SSH SUCCESSFUL LOGINS (RECENT) ═══${NC}"

    if [ -f /var/log/auth.log ]; then
        echo -e "${CYAN}Last 5 successful SSH logins:${NC}"
        grep "Accepted password" /var/log/auth.log 2>/dev/null | tail -5 | sed 's/^/  /' || echo "  No recent successful logins found"

        echo ""
        grep "Accepted publickey" /var/log/auth.log 2>/dev/null | tail -3 | sed 's/^/  /'
    fi
    echo ""
}

################################################################################
# Connection Statistics
################################################################################

show_connection_stats() {
    echo -e "${BLUE}═══ ACTIVE CONNECTIONS (SSH) ═══${NC}"

    echo -e "${CYAN}Active SSH connections:${NC}"
    local active_ssh=$(netstat -tn 2>/dev/null | grep -c ":22 " || ss -tn 2>/dev/null | grep -c ":22 " || echo "N/A")
    echo "  Total: $active_ssh"

    echo ""
    echo -e "${CYAN}Connection breakdown:${NC}"
    ss -tn 2>/dev/null | grep ":22 " | awk '{print $NF}' | sort | uniq -c | sort -rn | head -5 | sed 's/^/  /' || echo "  (Unable to determine)"
    echo ""
}

show_network_stats() {
    echo -e "${BLUE}═══ NETWORK STATISTICS ═══${NC}"

    echo -e "${CYAN}Open ports with listeners:${NC}"
    ss -tln 2>/dev/null | grep LISTEN | awk '{print $4}' | sort -u | sed 's/^/  /' || netstat -tln | grep LISTEN | sed 's/^/  /'
    echo ""
}

################################################################################
# System Alerts
################################################################################

show_security_alerts() {
    echo -e "${BLUE}═══ SECURITY ALERTS ═══${NC}"

    local alerts=0

    # Check for UFW status
    if ! systemctl is-active --quiet ufw; then
        echo -e "${RED}⚠ WARNING: UFW firewall is not active${NC}"
        ((alerts++))
    fi

    # Check for fail2ban status
    if ! systemctl is-active --quiet fail2ban; then
        echo -e "${RED}⚠ WARNING: fail2ban is not running${NC}"
        ((alerts++))
    fi

    # Check for excessive failed logins
    if [ -f /var/log/auth.log ]; then
        local recent_failures=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -100 | wc -l)
        if [ "$recent_failures" -gt 50 ]; then
            echo -e "${YELLOW}⚠ NOTICE: High number of failed login attempts ($recent_failures)${NC}"
            ((alerts++))
        fi
    fi

    # Check for banned IPs
    local banned=$(fail2ban-client status sshd 2>/dev/null | grep "Banned IP" | awk '{print $NF}' || echo "0")
    if [ "$banned" -gt 0 ] 2>/dev/null; then
        echo -e "${YELLOW}⚠ NOTICE: $banned IP(s) currently banned${NC}"
        ((alerts++))
    fi

    if [ $alerts -eq 0 ]; then
        echo -e "${GREEN}✓ No security alerts - System is operating normally${NC}"
    fi
    echo ""
}

################################################################################
# Dashboard Functions
################################################################################

show_full_dashboard() {
    clear_screen
    print_header
    print_timestamp

    show_ufw_status
    show_ufw_rules
    show_fail2ban_status
    show_ssh_jail_status
    show_banned_ips
    show_failed_logins
    show_successful_logins
    show_connection_stats
    show_security_alerts
}

tail_ufw_logs() {
    echo -e "${MAGENTA}UFW Log Monitoring (Press Ctrl+C to exit)${NC}"
    echo ""
    tail -f /var/log/ufw.log 2>/dev/null || echo "UFW log file not found"
}

tail_fail2ban_logs() {
    echo -e "${MAGENTA}fail2ban Log Monitoring (Press Ctrl+C to exit)${NC}"
    echo ""
    tail -f /var/log/fail2ban.log 2>/dev/null || echo "fail2ban log file not found"
}

tail_auth_logs() {
    echo -e "${MAGENTA}SSH Authentication Log Monitoring (Press Ctrl+C to exit)${NC}"
    echo ""
    tail -f /var/log/auth.log 2>/dev/null | grep -E "sshd|sudo" || echo "Auth log file not found"
}

watch_dashboard() {
    while true; do
        show_full_dashboard
        echo -e "${CYAN}Auto-refreshing every 5 seconds... (Press Ctrl+C to exit)${NC}"
        sleep 5
    done
}

################################################################################
# Help Function
################################################################################

show_help() {
    cat << 'EOF'
Linux Firewall Security - Monitoring Script

Usage: sudo bash monitor-firewall.sh [OPTION]

Options:
  dashboard      Show full security dashboard (default)
  watch          Auto-refresh dashboard every 5 seconds

  tail-ufw       Follow UFW log file in real-time
  tail-fail2ban  Follow fail2ban log file in real-time
  tail-auth      Follow SSH authentication log in real-time

  status         Show UFW and fail2ban status
  rules          Show firewall rules
  banned         Show banned IPs
  connections    Show active connections
  alerts         Show security alerts only

  help           Show this help message

Examples:
  sudo bash monitor-firewall.sh
  sudo bash monitor-firewall.sh watch
  sudo bash monitor-firewall.sh tail-ufw
  sudo bash monitor-firewall.sh banned

EOF
}

################################################################################
# Main Execution
################################################################################

main() {
    check_root

    local mode="${1:-dashboard}"

    case "$mode" in
        dashboard)
            show_full_dashboard
            ;;
        watch)
            watch_dashboard
            ;;
        tail-ufw)
            tail_ufw_logs
            ;;
        tail-fail2ban)
            tail_fail2ban_logs
            ;;
        tail-auth)
            tail_auth_logs
            ;;
        status)
            print_header
            print_timestamp
            show_ufw_status
            show_fail2ban_status
            ;;
        rules)
            print_header
            print_timestamp
            show_ufw_status
            show_ufw_rules
            ;;
        banned)
            print_header
            print_timestamp
            show_banned_ips
            ;;
        connections)
            print_header
            print_timestamp
            show_connection_stats
            show_network_stats
            ;;
        alerts)
            print_header
            print_timestamp
            show_security_alerts
            ;;
        help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $mode${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
