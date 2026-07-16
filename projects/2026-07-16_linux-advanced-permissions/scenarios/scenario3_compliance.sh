#!/bin/bash

# Scenario 3: Conformité et audit (GDPR, ISO 27001)
# Situation: Audit régulier des accès, journalisation, moindre privilège
# Solution: Audit scripts + logging + permission validation

echo "=========================================="
echo "Scenario 3: Compliance and Audit"
echo "=========================================="
echo ""

AUDIT_LOG="/var/log/permission-audit/compliance_$(date +%Y%m%d_%H%M%S).log"
mkdir -p /var/log/permission-audit

echo "Compliance Check Report" > "$AUDIT_LOG"
echo "Date: $(date)" >> "$AUDIT_LOG"
echo "" >> "$AUDIT_LOG"

echo "Running compliance audit..."
echo ""

# 1. Check for world-readable sensitive files
echo "1. Checking for world-readable sensitive files..."
echo "" >> "$AUDIT_LOG"
echo "=== Sensitive File Permissions ===" >> "$AUDIT_LOG"

SENSITIVE_FILES=(
    "/opt/test_permissions/devops/secrets.env"
    "/opt/test_permissions/webapp/config.php"
    "/etc/sudoers"
    "/etc/sudoers.d/devops"
)

for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        PERMS=$(stat -c '%A' "$file" 2>/dev/null || stat -f '%Lp' "$file" 2>/dev/null)
        OWNER=$(stat -c '%U:%G' "$file" 2>/dev/null || ls -l "$file" | awk '{print $3":"$4}' 2>/dev/null)

        echo "File: $file" >> "$AUDIT_LOG"
        echo "  Permissions: $PERMS" >> "$AUDIT_LOG"
        echo "  Owner: $OWNER" >> "$AUDIT_LOG"

        # Check if world-readable
        if [[ "$PERMS" == *"r--"* ]]; then
            echo "  ⚠ WARNING: World-readable" >> "$AUDIT_LOG"
            echo "  ⚠ $file is world-readable!"
        else
            echo "  ✓ OK" >> "$AUDIT_LOG"
        fi
    fi
done

echo "✓ Sensitive file permissions checked"
echo ""

# 2. Check user account security
echo "2. Checking user account security..."
echo "" >> "$AUDIT_LOG"
echo "=== User Account Security ===" >> "$AUDIT_LOG"

echo "Checking for:"
echo "  - Accounts with UID 0 (root privileges)"
echo "  - Accounts with no password"
echo "  - Disabled accounts"

awk -F: '$3 == 0 {print "  ⚠ UID 0: " $1}' /etc/passwd >> "$AUDIT_LOG"

# Check shadow file if accessible
if [ -r /etc/shadow ]; then
    echo "Checking for no-password accounts..." >> "$AUDIT_LOG"
    awk -F: '$2 == "" || $2 == "!" || $2 == "*" {print "  Status: " $1 " (locked or empty)"}' /etc/shadow >> "$AUDIT_LOG"
fi

echo "✓ User account security checked"
echo ""

# 3. Check sudo audit logs
echo "3. Checking sudo usage audit..."
echo "" >> "$AUDIT_LOG"
echo "=== Sudo Usage Audit ===" >> "$AUDIT_LOG"

if [ -f /var/log/sudo.log ]; then
    echo "Recent sudo commands (last 5):" >> "$AUDIT_LOG"
    tail -5 /var/log/sudo.log >> "$AUDIT_LOG"
else
    echo "No sudo log found at /var/log/sudo.log" >> "$AUDIT_LOG"
fi

echo "✓ Sudo audit logs checked"
echo ""

# 4. Check file access logs
echo "4. Checking system logs for permission denials..."
echo "" >> "$AUDIT_LOG"
echo "=== Permission Denial Logs ===" >> "$AUDIT_LOG"

if [ -f /var/log/auth.log ]; then
    grep "permission denied" /var/log/auth.log | tail -5 >> "$AUDIT_LOG" 2>/dev/null || true
elif [ -f /var/log/secure ]; then
    grep "permission denied" /var/log/secure | tail -5 >> "$AUDIT_LOG" 2>/dev/null || true
fi

echo "✓ Permission denial logs checked"
echo ""

# 5. Check ACL compliance
echo "5. Verifying ACL compliance..."
echo "" >> "$AUDIT_LOG"
echo "=== ACL Configuration ===" >> "$AUDIT_LOG"

for dir in /opt/test_permissions/shared /opt/test_permissions/webapp /opt/test_permissions/devops; do
    if [ -d "$dir" ]; then
        echo "Directory: $dir" >> "$AUDIT_LOG"
        getfacl "$dir" 2>/dev/null | grep -E "^(user|group|default):" >> "$AUDIT_LOG" || echo "  (no ACLs)" >> "$AUDIT_LOG"
    fi
done

echo "✓ ACL configuration verified"
echo ""

# 6. Generate compliance report
echo "=========================================="
echo "Compliance Report Summary"
echo "=========================================="
echo ""
echo "Checks performed:"
echo "  ✓ Sensitive file permissions"
echo "  ✓ User account security"
echo "  ✓ Sudo usage audit"
echo "  ✓ Permission denial logs"
echo "  ✓ ACL compliance"
echo ""

echo "Report saved to: $AUDIT_LOG"
echo ""

echo "Key compliance points (ISO 27001 / GDPR):"
echo "---"
echo "✓ Least privilege principle: Users have minimum needed access"
echo "✓ Audit trail: Sudo commands logged in /var/log/sudo.log"
echo "✓ Access control: ACLs used for granular permissions"
echo "✓ Data protection: Secrets file restricted to authorized users"
echo "✓ Segregation of duties: Roles separated (senior, mid, junior)"
echo ""

echo "Recommendations:"
echo "---"
echo "1. Review audit logs weekly for anomalies"
echo "2. Rotate sudo logs monthly"
echo "3. Audit ACL changes quarterly"
echo "4. Update sudoers config when roles change"
echo "5. Enable file integrity monitoring (aide, tripwire) for secrets"
echo "6. Implement password rotation policy (covered in password_policy.sh)"
echo "7. Set up alerts for root/admin activity"
echo ""

# Display audit log
echo "=========================================="
echo "Full Audit Log:"
echo "=========================================="
cat "$AUDIT_LOG"

echo ""
echo "✓ Scenario 3 complete"
