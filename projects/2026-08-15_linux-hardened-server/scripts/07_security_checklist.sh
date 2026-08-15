#!/bin/bash
# 07_security_checklist.sh - Security Verification Checklist
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

[[ $EUID -ne 0 ]] && fail "This script must be run as root" && exit 1

PASSED=0
FAILED=0
WARNINGS=0

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          Security Hardening Verification Checklist            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

echo "=== 1. SYSTEM UPDATES ==="
if apt-get -s upgrade | grep -q "^0 upgraded"; then
    log "System is up to date"
    ((PASSED++))
else
    warning "Updates available"
    ((WARNINGS++))
fi

echo ""
echo "=== 2. FIREWALL CONFIGURATION ==="
systemctl is-active --quiet ufw && { log "UFW firewall is active"; ((PASSED++)); } || { fail "UFW not active"; ((FAILED++)); }
ufw status | grep -q "Status: active" && { log "UFW enabled"; ((PASSED++)); } || { fail "UFW not enabled"; ((FAILED++)); }
ufw status | grep -q "Default: deny" && { log "Default deny policy set"; ((PASSED++)); } || { fail "Default policy issue"; ((FAILED++)); }

echo ""
echo "=== 3. SSH HARDENING ==="
grep -q "^PermitRootLogin no" /etc/ssh/sshd_config && { log "Root login disabled"; ((PASSED++)); } || { fail "Root login not disabled"; ((FAILED++)); }
grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config && { log "Password auth disabled"; ((PASSED++)); } || { warning "Password auth not disabled"; ((WARNINGS++)); }
sshd -t 2>/dev/null && { log "SSH config valid"; ((PASSED++)); } || { fail "SSH config invalid"; ((FAILED++)); }

echo ""
echo "=== 4. USER SECURITY ==="
[ "$(getent shadow root | cut -d: -f2)" = "!" ] && { log "Root account locked"; ((PASSED++)); } || { warning "Root not locked"; ((WARNINGS++)); }
EMPTY_PASSWORDS=$(awk -F: '($2 == "")' /etc/shadow | wc -l)
[ "$EMPTY_PASSWORDS" -eq 0 ] && { log "No empty passwords"; ((PASSED++)); } || { fail "Empty passwords found"; ((FAILED++)); }

echo ""
echo "=== 5. FAIL2BAN ==="
systemctl is-active --quiet fail2ban && { log "Fail2ban active"; ((PASSED++)); } || { warning "Fail2ban not active"; ((WARNINGS++)); }

echo ""
echo "=== 6. AUDIT DAEMON ==="
systemctl is-active --quiet auditd && { log "Auditd active"; ((PASSED++)); } || { warning "Auditd not active"; ((WARNINGS++)); }

echo ""
echo "=== 7. KERNEL HARDENING ==="
[ "$(sysctl -n net.ipv4.ip_forward)" = "0" ] && { log "IP forwarding disabled"; ((PASSED++)); } || { warning "IP forwarding enabled"; ((WARNINGS++)); }
[ "$(sysctl -n net.ipv4.tcp_syncookies)" = "1" ] && { log "SYN cookies enabled"; ((PASSED++)); } || { fail "SYN cookies disabled"; ((FAILED++)); }

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    SECURITY AUDIT SUMMARY                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Passed:${NC}    $PASSED checks"
echo -e "${YELLOW}Warnings:${NC}  $WARNINGS checks"
echo -e "${RED}Failed:${NC}    $FAILED checks"
echo ""

TOTAL=$((PASSED + FAILED + WARNINGS))
SCORE=$((PASSED * 100 / TOTAL))
echo "Security Score: ${SCORE}%"
echo ""

[ "$FAILED" -eq 0 ] && echo -e "${GREEN}✓ All critical measures are in place!${NC}" || echo -e "${RED}✗ Fix failed checks${NC}"
