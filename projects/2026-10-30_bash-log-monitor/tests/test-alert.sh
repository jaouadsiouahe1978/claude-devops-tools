#!/bin/bash

# Test script for Log Monitor
# Simulates various error conditions to trigger alerts

TEST_LOG="/tmp/test-system.log"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_MONITOR="${PROJECT_DIR}/bin/log-monitor.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Create test configuration
create_test_config() {
    print_test "Creating test configuration..."

    cat > /tmp/test-monitor.conf <<EOF
LOGS_TO_MONITOR="$TEST_LOG"
ALERT_EMAIL="test@localhost"
ALERT_DIR="/tmp/test-alerts"
LOG_MONITOR_LOG="/tmp/test-alerts/monitor.log"
DRY_RUN=true
EOF

    mkdir -p /tmp/test-alerts
    print_success "Test configuration created"
}

# Initialize test log
init_test_log() {
    print_test "Initializing test log..."

    # Create test log with clean data
    cat > "$TEST_LOG" <<'EOF'
2026-10-30 08:00:00 System started
2026-10-30 08:00:05 All services running normally
2026-10-30 08:01:00 INFO: Routine backup started
EOF

    chmod 644 "$TEST_LOG"
    print_success "Test log created at $TEST_LOG"
}

# Test 1: Error pattern detection
test_error_detection() {
    print_test "Test 1: Error Pattern Detection"

    # Add error line to log
    echo "2026-10-30 08:02:00 ERROR: Database connection failed" >> "$TEST_LOG"

    print_success "Added ERROR pattern to log"

    # Run monitor
    if "$LOG_MONITOR" --config /tmp/test-monitor.conf; then
        print_success "Monitor ran successfully for error detection"
    else
        print_error "Monitor failed on error detection test"
    fi
}

# Test 2: Authentication failure detection
test_auth_failure() {
    print_test "Test 2: Authentication Failure Detection"

    echo "2026-10-30 08:03:00 Failed password for invalid user admin" >> "$TEST_LOG"

    print_success "Added authentication failure pattern"

    if "$LOG_MONITOR" --config /tmp/test-monitor.conf; then
        print_success "Monitor ran successfully for auth failure"
    else
        print_error "Monitor failed on auth failure test"
    fi
}

# Test 3: System resource issue detection
test_resource_issue() {
    print_test "Test 3: System Resource Issue Detection"

    echo "2026-10-30 08:04:00 kernel: Out of memory: Kill process nginx" >> "$TEST_LOG"

    print_success "Added OOM killer pattern"

    if "$LOG_MONITOR" --config /tmp/test-monitor.conf; then
        print_success "Monitor ran successfully for resource issue"
    else
        print_error "Monitor failed on resource issue test"
    fi
}

# Test 4: Network connectivity issue
test_network_issue() {
    print_test "Test 4: Network Connectivity Issue Detection"

    echo "2026-10-30 08:05:00 Connection refused for host 192.168.1.100" >> "$TEST_LOG"

    print_success "Added connection refused pattern"

    if "$LOG_MONITOR" --config /tmp/test-monitor.conf; then
        print_success "Monitor ran successfully for network issue"
    else
        print_error "Monitor failed on network issue test"
    fi
}

# Test 5: Permission denied
test_permission_denied() {
    print_test "Test 5: Permission Denied Detection"

    echo "2026-10-30 08:06:00 Permission denied for /var/log/secure" >> "$TEST_LOG"

    print_success "Added permission denied pattern"

    if "$LOG_MONITOR" --config /tmp/test-monitor.conf; then
        print_success "Monitor ran successfully for permission issue"
    else
        print_error "Monitor failed on permission test"
    fi
}

# Test 6: Segmentation fault
test_segfault() {
    print_test "Test 6: Segmentation Fault Detection"

    echo "2026-10-30 08:07:00 Process httpd (PID: 1234) caused a segmentation fault" >> "$TEST_LOG"

    print_success "Added segmentation fault pattern"

    if "$LOG_MONITOR" --config /tmp/test-monitor.conf; then
        print_success "Monitor ran successfully for segfault detection"
    else
        print_error "Monitor failed on segfault test"
    fi
}

# Test 7: Verify alert archiving
test_alert_archiving() {
    print_test "Test 7: Alert Archiving Verification"

    if [[ -d /tmp/test-alerts ]] && [[ -n "$(ls -A /tmp/test-alerts/*.alert 2>/dev/null)" ]]; then
        print_success "Alerts were successfully archived"
        echo ""
        print_test "Alert files created:"
        ls -lah /tmp/test-alerts/*.alert 2>/dev/null | awk '{print "  " $NF}'
    else
        print_error "No alerts were archived"
    fi
}

# Clean up test data
cleanup() {
    print_test "Cleaning up test data..."

    # Don't remove logs yet - user might want to inspect
    # But remove old test logs from previous runs
    find /tmp -name "test-system.log*" -mtime +1 -delete 2>/dev/null || true

    print_success "Cleanup complete"
}

# Show test results
show_results() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Test Log Location:${NC} $TEST_LOG"
    echo -e "${GREEN}Alert Directory:${NC} /tmp/test-alerts"
    echo -e "${GREEN}Monitor Log:${NC} /tmp/test-alerts/monitor.log"
    echo ""
    echo "Inspect results:"
    echo "  cat $TEST_LOG"
    echo "  cat /tmp/test-alerts/monitor.log"
    echo "  ls -lah /tmp/test-alerts/"
    echo ""
}

# Main test runner
main() {
    echo -e "${BLUE}"
    cat <<'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║              Log Monitor - Test Suite                                     ║
║              Testing alert pattern detection                              ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    create_test_config
    init_test_log

    echo ""
    echo -e "${BLUE}Running Tests...${NC}"
    echo ""

    test_error_detection
    echo ""
    test_auth_failure
    echo ""
    test_resource_issue
    echo ""
    test_network_issue
    echo ""
    test_permission_denied
    echo ""
    test_segfault
    echo ""
    test_alert_archiving

    cleanup
    show_results
}

# Run tests
main "$@"
