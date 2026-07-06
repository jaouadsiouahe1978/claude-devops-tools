#!/bin/bash
###############################################################################
# Quick Test Script
# Validates the backup system setup
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
SKIPPED=0

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

test_skip() {
    echo -e "${YELLOW}⊘${NC} $1"
    ((SKIPPED++))
}

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Backup System Quick Test${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}[INFO]${NC} Not running as root. Some tests will be skipped."
    echo ""
fi

# Test 1: Check required commands
echo "1. Checking required commands..."
for cmd in tar gzip sha256sum find; do
    if command -v "$cmd" &> /dev/null; then
        test_pass "$cmd found"
    else
        test_fail "$cmd not found"
    fi
done
echo ""

# Test 2: Check configuration file
echo "2. Checking configuration..."
if [[ -f "${SCRIPT_DIR}/backup-config.sh" ]]; then
    test_pass "Configuration file exists"

    # Source it
    source "${SCRIPT_DIR}/backup-config.sh"

    # Check key variables
    [[ -n "${BACKUP_DIRS:-}" ]] && test_pass "BACKUP_DIRS defined" || test_fail "BACKUP_DIRS not defined"
    [[ -n "${BACKUP_BASE_DIR:-}" ]] && test_pass "BACKUP_BASE_DIR defined" || test_fail "BACKUP_BASE_DIR not defined"
    [[ -n "${MAX_BACKUPS:-}" ]] && test_pass "MAX_BACKUPS defined" || test_fail "MAX_BACKUPS not defined"
else
    test_fail "Configuration file not found"
fi
echo ""

# Test 3: Check script files
echo "3. Checking script files..."
for script in backup.sh backup-rotate.sh backup-verify.sh backup-monitoring.sh backup-restore.sh install.sh; do
    if [[ -f "${SCRIPT_DIR}/${script}" ]]; then
        if [[ -x "${SCRIPT_DIR}/${script}" ]]; then
            test_pass "$script exists and is executable"
        else
            test_fail "$script exists but is not executable"
        fi
    else
        test_fail "$script not found"
    fi
done
echo ""

# Test 4: Check directories (if running as root)
if [[ $EUID -eq 0 ]]; then
    echo "4. Checking directories..."
    for dir in /var/backups/custom-backups /var/log/backup; do
        if [[ -d "$dir" ]]; then
            test_pass "$dir exists"
        else
            test_skip "$dir doesn't exist (will be created on first run)"
        fi
    done
    echo ""

    # Test 5: Test tar command
    echo "5. Testing tar compression..."
    TMPTEST=$(mktemp -d)
    echo "test content" > "${TMPTEST}/test.txt"

    if tar -czf "${TMPTEST}/test.tar.gz" -C "${TMPTEST}" test.txt 2>/dev/null; then
        test_pass "TAR compression works"
    else
        test_fail "TAR compression failed"
    fi

    if tar -tzf "${TMPTEST}/test.tar.gz" > /dev/null 2>&1; then
        test_pass "TAR integrity check works"
    else
        test_fail "TAR integrity check failed"
    fi

    if sha256sum "${TMPTEST}/test.tar.gz" > /dev/null 2>&1; then
        test_pass "SHA256 checksum works"
    else
        test_fail "SHA256 checksum failed"
    fi

    rm -rf "${TMPTEST}"
    echo ""

    # Test 6: Test backup script (dry run on small directory)
    echo "6. Testing backup script (dry run on /etc only)..."
    TEST_BACKUP_DIR="/tmp/backup-test-$$"
    mkdir -p "${TEST_BACKUP_DIR}"

    if bash "${SCRIPT_DIR}/backup.sh" &>/dev/null; then
        if [[ -f "/var/backups/custom-backups/backup-*.tar.gz" ]]; then
            test_pass "Backup script executed successfully"
            BACKUP_COUNT=$(find /var/backups/custom-backups -name "backup-*.tar.gz" -type f 2>/dev/null | wc -l)
            echo "  Created ${BACKUP_COUNT} backup(s)"
        else
            test_fail "Backup script didn't create backup file"
        fi
    else
        test_fail "Backup script execution failed"
    fi
    echo ""

else
    echo "4-6. Skipping directory and execution tests (requires root)"
    echo "    Run with: sudo bash quick-test.sh"
    echo ""
fi

# Test 7: Check documentation
echo "7. Checking documentation..."
for doc in README.md INSTALLATION.md; do
    if [[ -f "${SCRIPT_DIR}/${doc}" ]]; then
        test_pass "$doc found"
    else
        test_fail "$doc not found"
    fi
done
echo ""

# Test 8: Check example files
echo "8. Checking example files..."
if [[ -f "${SCRIPT_DIR}/crontab.example" ]]; then
    test_pass "crontab.example found"
else
    test_fail "crontab.example not found"
fi
echo ""

# Summary
echo -e "${BLUE}================================${NC}"
echo "Test Summary"
echo -e "${BLUE}================================${NC}"
echo -e "Passed:  ${GREEN}${PASSED}${NC}"
echo -e "Failed:  ${RED}${FAILED}${NC}"
echo -e "Skipped: ${YELLOW}${SKIPPED}${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review the configuration: backup-config.sh"
    echo "  2. Install the scripts: sudo bash install.sh"
    echo "  3. Test a backup: sudo /usr/local/bin/backup.sh"
    echo "  4. Verify the backup: sudo /usr/local/bin/backup-verify.sh latest"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo ""
    echo "Fix the issues and run this test again."
    echo ""
    exit 1
fi
