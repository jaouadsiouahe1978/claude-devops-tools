#!/bin/bash
# Test suite for log monitor

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
TEST_DIR="$SCRIPT_DIR/tests"
LOG_DIR="${TEST_DIR}/test-logs"
STATE_DIR="/tmp/log-monitor-test"

source "$PROJECT_DIR/scripts/utils.sh"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

passed=0
failed=0

# Fonction de test
assert_true() {
    local test_name=$1
    local condition=$2

    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $test_name"
        ((failed++))
    fi
}

assert_file_contains() {
    local test_name=$1
    local file=$2
    local pattern=$3

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $test_name"
        ((failed++))
    fi
}

# Setup
setup() {
    mkdir -p "$LOG_DIR"
    mkdir -p "$STATE_DIR"
    export STATE_DIR
    export ALERT_CACHE="${STATE_DIR}/alert.cache"
}

# Cleanup
cleanup() {
    rm -rf "$STATE_DIR"
    rm -f "${LOG_DIR}"/*.log
}

# Tests

echo "================================"
echo "  Log Monitor Test Suite v1.0"
echo "================================"
echo ""

# Test 1: Config loading
echo "Test 1: Configuration Loading"
export CONFIG_FILE="$PROJECT_DIR/config/log-monitor.conf"
export DEBUG=0
setup

assert_true "Config file exists" "[[ -f '$CONFIG_FILE' ]]"
assert_true "Log files defined" "[[ -n '$LOG_FILES' ]]"
assert_true "Alert email defined" "[[ -n '${ALERT_EMAIL:-}' ]]"

echo ""

# Test 2: Utility functions
echo "Test 2: Utility Functions"

assert_true "log function exists" "type log >/dev/null 2>&1"
assert_true "should_alert function exists" "type should_alert >/dev/null 2>&1"
assert_true "get_context function exists" "type get_context >/dev/null 2>&1"

echo ""

# Test 3: Pattern matching
echo "Test 3: Pattern Matching"

# Créer un test log
echo "2026-09-27 10:15:23 INFO: Application started" > "${LOG_DIR}/test.log"
echo "2026-09-27 10:15:25 ERROR: Database connection failed" >> "${LOG_DIR}/test.log"
echo "2026-09-27 10:15:26 CRITICAL: Memory allocation error" >> "${LOG_DIR}/test.log"

assert_file_contains "Log contains ERROR" "${LOG_DIR}/test.log" "ERROR"
assert_file_contains "Log contains CRITICAL" "${LOG_DIR}/test.log" "CRITICAL"
assert_file_contains "Log contains INFO" "${LOG_DIR}/test.log" "INFO"

echo ""

# Test 4: Context retrieval
echo "Test 4: Context Retrieval"

local context=$(get_context "${LOG_DIR}/test.log" "ERROR")
assert_true "Context retrieval works" "[[ -n '$context' ]]"
assert_true "Context contains ERROR" "echo '$context' | grep -q 'ERROR'"

echo ""

# Test 5: Alert throttling
echo "Test 5: Alert Throttling"

export ALERT_THROTTLE_SECONDS=2

# First alert should be allowed
assert_true "First alert allowed" "should_alert 'test:error'"

# Second alert immediately should be blocked
assert_true "Second alert blocked (throttled)" "! should_alert 'test:error'"

echo ""

# Test 6: Script execution
echo "Test 6: Script Execution"

assert_true "log-monitor.sh is executable" "[[ -x '$PROJECT_DIR/scripts/log-monitor.sh' ]]"
assert_true "utils.sh is readable" "[[ -r '$PROJECT_DIR/scripts/utils.sh' ]]"
assert_true "Service file exists" "[[ -f '$PROJECT_DIR/systemd/log-monitor.service' ]]"

echo ""

# Test 7: Regex patterns
echo "Test 7: Pattern Matching Regex"

local test_line="2026-09-27 10:15:26 CRITICAL: System failure"
local pattern="CRITICAL|FATAL|PANIC"

assert_true "Regex matches CRITICAL" "[[ '$test_line' =~ $pattern ]]"

echo ""

# Test 8: File monitoring
echo "Test 8: File Monitoring Setup"

assert_true "Log directory exists" "[[ -d '$LOG_DIR' ]]"
assert_true "State directory exists" "[[ -d '$STATE_DIR' ]]"
assert_true "Test log file created" "[[ -f '${LOG_DIR}/test.log' ]]"

echo ""

# Résumé
echo "================================"
echo "  Test Results"
echo "================================"
echo -e "Passed: ${GREEN}$passed${NC}"
echo -e "Failed: ${RED}$failed${NC}"
echo ""

cleanup

if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
