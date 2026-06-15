#!/bin/bash

# Test Runner for Log Monitoring System
# Runs unit and integration tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/monitoring.conf"
TEST_LOG="${SCRIPT_DIR}/tests/test-logs/test.log"
PASS=0
FAIL=0

mkdir -p "$(dirname "$TEST_LOG")"
source "$CONFIG_FILE"

# ============================================================
# TEST UTILITIES
# ============================================================

test_pass() {
    echo "✓ $1"
    ((PASS++))
}

test_fail() {
    echo "✗ $1"
    ((FAIL++))
}

assert_equals() {
    local expected=$1
    local actual=$2
    local test_name=$3

    if [[ "$expected" == "$actual" ]]; then
        test_pass "$test_name"
    else
        test_fail "$test_name (expected: $expected, got: $actual)"
    fi
}

assert_file_exists() {
    local file=$1
    local test_name=${2:-"File exists: $file"}

    if [[ -f "$file" ]]; then
        test_pass "$test_name"
    else
        test_fail "$test_name"
    fi
}

# ============================================================
# TEST SUITE
# ============================================================

test_config_loading() {
    echo ""
    echo "TEST: Configuration Loading"

    if [[ -f "$CONFIG_FILE" ]]; then
        test_pass "Config file found"
    else
        test_fail "Config file not found"
    fi

    if [[ ${#LOG_PATHS[@]} -gt 0 ]]; then
        test_pass "LOG_PATHS defined"
    else
        test_fail "LOG_PATHS not defined"
    fi

    if [[ -n "$ALERT_THRESHOLD_ERROR" ]]; then
        test_pass "Alert threshold defined"
    else
        test_fail "Alert threshold not defined"
    fi
}

test_log_generation() {
    echo ""
    echo "TEST: Log File Generation"

    # Create test log
    {
        echo "[2026-06-15 10:00:01] INFO Starting application"
        echo "[2026-06-15 10:00:02] ERROR Failed to connect to database"
        echo "[2026-06-15 10:00:03] WARN Connection timeout"
        echo "[2026-06-15 10:00:04] ERROR Invalid credentials"
        echo "[2026-06-15 10:00:05] INFO Connection established"
    } > "$TEST_LOG"

    assert_file_exists "$TEST_LOG" "Test log created"
    assert_equals "5" "$(wc -l < $TEST_LOG)" "Test log has correct line count"
}

test_pattern_matching() {
    echo ""
    echo "TEST: Pattern Matching"

    [[ ! -f "$TEST_LOG" ]] && test_log_generation

    local error_count=$(grep -c "ERROR" "$TEST_LOG" 2>/dev/null || echo 0)
    local warn_count=$(grep -c "WARN" "$TEST_LOG" 2>/dev/null || echo 0)
    local info_count=$(grep -c "INFO" "$TEST_LOG" 2>/dev/null || echo 0)

    assert_equals "2" "$error_count" "Error count detection"
    assert_equals "1" "$warn_count" "Warning count detection"
    assert_equals "2" "$info_count" "Info count detection"
}

test_scripts_executable() {
    echo ""
    echo "TEST: Scripts Permissions"

    local scripts=(
        "${SCRIPT_DIR}/scripts/log-monitor.sh"
        "${SCRIPT_DIR}/scripts/log-analyzer.sh"
        "${SCRIPT_DIR}/scripts/log-rotator.sh"
        "${SCRIPT_DIR}/scripts/report-generator.sh"
        "${SCRIPT_DIR}/scripts/alert-manager.sh"
    )

    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            test_pass "$(basename $script) executable"
        else
            test_fail "$(basename $script) not executable"
        fi
    done
}

test_analyzer_function() {
    echo ""
    echo "TEST: Log Analyzer"

    [[ ! -f "$TEST_LOG" ]] && test_log_generation

    # Test analyzer script
    if bash "$SCRIPT_DIR/scripts/log-analyzer.sh" "$TEST_LOG" > /tmp/analyzer_output.txt 2>&1; then
        test_pass "Analyzer runs without error"
        grep -qi "Errors:" /tmp/analyzer_output.txt && test_pass "Analyzer detects errors" || test_fail "Analyzer doesn't detect errors"
    else
        test_fail "Analyzer execution failed"
    fi
}

test_report_generation() {
    echo ""
    echo "TEST: Report Generation"

    # Create sample alert log
    {
        echo "[2026-06-15 10:00:01] [ERROR] Test error 1"
        echo "[2026-06-15 10:00:02] [WARN] Test warning"
        echo "[2026-06-15 10:00:03] [ERROR] Test error 2"
    } > "$ALERT_LOG_FILE"

    # Generate CSV report
    bash "$SCRIPT_DIR/scripts/report-generator.sh" "2026-06-15" "csv" > /tmp/report_output.txt 2>&1

    if [[ -f "${REPORT_OUTPUT_DIR}/report-2026-06-15.csv" ]]; then
        test_pass "CSV report generated"
    else
        test_fail "CSV report not found"
    fi
}

test_directories() {
    echo ""
    echo "TEST: Directory Structure"

    local dirs=(
        "${SCRIPT_DIR}/config"
        "${SCRIPT_DIR}/scripts"
        "${SCRIPT_DIR}/cron"
        "${SCRIPT_DIR}/tests"
        "${SCRIPT_DIR}/data"
    )

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            test_pass "Directory exists: $(basename $dir)"
        else
            test_fail "Directory missing: $(basename $dir)"
        fi
    done
}

# ============================================================
# CLEANUP
# ============================================================

cleanup() {
    echo ""
    echo "Cleaning up test files..."
    rm -f "$TEST_LOG"
    rm -f /tmp/analyzer_output.txt /tmp/report_output.txt
}

# ============================================================
# MAIN TEST EXECUTION
# ============================================================

echo "╔════════════════════════════════════════════════════╗"
echo "║  Log Monitoring System - Test Suite                ║"
echo "╚════════════════════════════════════════════════════╝"

test_config_loading
test_directories
test_scripts_executable
test_log_generation
test_pattern_matching
test_analyzer_function
test_report_generation

cleanup

# Summary
echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║  Test Results                                       ║"
echo "╠════════════════════════════════════════════════════╣"
echo "║  ✓ Passed: $PASS"
echo "║  ✗ Failed: $FAIL"
echo "║  Total:   $((PASS + FAIL))"

if [[ $FAIL -eq 0 ]]; then
    echo "║  Status: ✓ ALL TESTS PASSED"
else
    echo "║  Status: ✗ SOME TESTS FAILED"
fi

echo "╚════════════════════════════════════════════════════╝"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
