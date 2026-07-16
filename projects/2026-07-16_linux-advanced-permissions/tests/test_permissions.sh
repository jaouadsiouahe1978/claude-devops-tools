#!/bin/bash

# Suite de tests pour valider les permissions

TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
    local test_name=$1
    local result=$2

    if [ "$result" -eq 0 ]; then
        echo "✓ $test_name"
        ((TESTS_PASSED++))
    else
        echo "✗ $test_name"
        ((TESTS_FAILED++))
    fi
}

echo "=========================================="
echo "Permission Configuration Tests"
echo "=========================================="
echo ""

# Test 1: Répertoires existent
echo "Test Suite 1: Directory Structure"
echo "---"

test -d /opt/test_permissions && test_result "Directory /opt/test_permissions exists" 0 || test_result "Directory /opt/test_permissions exists" 1
test -d /opt/test_permissions/shared && test_result "Directory shared exists" 0 || test_result "Directory shared exists" 1
test -d /opt/test_permissions/webapp && test_result "Directory webapp exists" 0 || test_result "Directory webapp exists" 1
test -d /opt/test_permissions/devops && test_result "Directory devops exists" 0 || test_result "Directory devops exists" 1

echo ""
echo "Test Suite 2: User & Group Creation"
echo "---"

getent passwd alice &>/dev/null && test_result "User alice created" 0 || test_result "User alice created" 1
getent passwd bob &>/dev/null && test_result "User bob created" 0 || test_result "User bob created" 1
getent passwd charlie &>/dev/null && test_result "User charlie created" 0 || test_result "User charlie created" 1
getent passwd diana &>/dev/null && test_result "User diana created" 0 || test_result "User diana created" 1
getent passwd eve &>/dev/null && test_result "User eve created" 0 || test_result "User eve created" 1

getent group webapp &>/dev/null && test_result "Group webapp created" 0 || test_result "Group webapp created" 1
getent group devops &>/dev/null && test_result "Group devops created" 0 || test_result "Group devops created" 1
getent group shared &>/dev/null && test_result "Group shared created" 0 || test_result "Group shared created" 1

echo ""
echo "Test Suite 3: File Permissions"
echo "---"

# Test permissions on devops directory
PERMS=$(stat -c '%a' /opt/test_permissions/devops 2>/dev/null || stat -f '%OLp' /opt/test_permissions/devops 2>/dev/null)
[ "$PERMS" = "750" ] && test_result "Devops directory is 750" 0 || test_result "Devops directory is 750" 1

# Test secrets.env is restricted
PERMS=$(stat -c '%a' /opt/test_permissions/devops/secrets.env 2>/dev/null || stat -f '%OLp' /opt/test_permissions/devops/secrets.env 2>/dev/null)
[ "$PERMS" = "600" ] && test_result "secrets.env is 600 (restricted)" 0 || test_result "secrets.env is 600 (restricted)" 1

echo ""
echo "Test Suite 4: ACL Configuration"
echo "---"

# Check if ACLs are configured
if command -v getfacl &> /dev/null; then
    # Test ACL on shared/project.txt
    getfacl /opt/test_permissions/shared/project.txt 2>/dev/null | grep -q "user:alice:r--" && test_result "alice has read ACL on project.txt" 0 || test_result "alice has read ACL on project.txt" 1

    # Test ACL on webapp/config.php
    getfacl /opt/test_permissions/webapp/config.php 2>/dev/null | grep -q "user:alice:rw-" && test_result "alice has read/write ACL on config.php" 0 || test_result "alice has read/write ACL on config.php" 1

    # Test ACL on deploy.sh
    getfacl /opt/test_permissions/devops/deploy.sh 2>/dev/null | grep -q "group:devops:r-x" && test_result "devops group has read/execute ACL on deploy.sh" 0 || test_result "devops group has read/execute ACL on deploy.sh" 1
else
    echo "⚠ ACL tools (getfacl) not available, skipping ACL tests"
fi

echo ""
echo "Test Suite 5: Sudo Configuration"
echo "---"

if [ -f /etc/sudoers.d/devops ]; then
    test_result "Sudo config file exists" 0

    grep -q "%devops" /etc/sudoers.d/devops && test_result "Devops group in sudo config" 0 || test_result "Devops group in sudo config" 1
    grep -q "diana" /etc/sudoers.d/devops && test_result "Diana in sudo config" 0 || test_result "Diana in sudo config" 1
    grep -q "NOPASSWD" /etc/sudoers.d/devops && test_result "NOPASSWD entries exist" 0 || test_result "NOPASSWD entries exist" 1
else
    test_result "Sudo config file exists" 1
fi

echo ""
echo "Test Suite 6: Password Policy"
echo "---"

grep -q "PASS_MAX_DAYS 90" /etc/login.defs && test_result "Password max age set to 90 days" 0 || test_result "Password max age set to 90 days" 1
grep -q "PASS_MIN_DAYS 1" /etc/login.defs && test_result "Password min age set to 1 day" 0 || test_result "Password min age set to 1 day" 1

echo ""
echo "Test Suite 7: Audit Logging"
echo "---"

[ -d /var/log/permission-audit ] && test_result "Audit directory exists" 0 || test_result "Audit directory exists" 1

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo ""
    echo "✓ All tests passed!"
    exit 0
else
    echo ""
    echo "✗ Some tests failed. Review the setup steps above."
    exit 1
fi
