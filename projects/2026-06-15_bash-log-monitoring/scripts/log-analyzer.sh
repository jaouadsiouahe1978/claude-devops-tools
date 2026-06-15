#!/bin/bash

# Advanced Log Analyzer
# Analyzes logs and provides detailed statistics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ============================================================
# FUNCTIONS
# ============================================================

print_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════"
}

analyze_log() {
    local logfile=$1
    local error_pattern=${2:-"ERROR|CRITICAL|FATAL"}
    local warn_pattern=${3:-"WARN|WARNING"}

    if [[ ! -f "$logfile" ]]; then
        echo "ERROR: File not found: $logfile"
        return 1
    fi

    print_header "Log Analysis: $logfile"

    # Total lines
    local total_lines=$(wc -l < "$logfile")
    echo "📊 Total lines: $total_lines"

    # Count severity levels
    local error_count=$(grep -c "$error_pattern" "$logfile" 2>/dev/null || echo 0)
    local warn_count=$(grep -c "$warn_pattern" "$logfile" 2>/dev/null || echo 0)

    echo ""
    echo "🔴 Errors: $error_count"
    echo "🟡 Warnings: $warn_count"
    echo "Ratio: $(echo "scale=2; ($error_count + $warn_count) * 100 / $total_lines" | bc)% issues"

    # Error breakdown
    if [[ $error_count -gt 0 ]]; then
        print_header "Top Error Types"
        grep "$error_pattern" "$logfile" | \
            sed 's/.*\(ERROR\|CRITICAL\|FATAL\)[^:]*:\s*\([^/]*\).*/\2/' | \
            sort | uniq -c | sort -rn | head -10 | \
            awk '{printf "  %3d × %s\n", $1, substr($0, 6)}'
    fi

    # Timeline analysis
    print_header "Timeline (Last 24 hours)"
    awk '{print substr($1, 1, 10)}' "$logfile" 2>/dev/null | sort | uniq -c | sort -k2 | tail -24 | \
        awk '{printf "%s: %3d events\n", $2, $1}'

    # Most recent errors
    if [[ $error_count -gt 0 ]]; then
        print_header "Most Recent Errors (last 5)"
        grep "$error_pattern" "$logfile" | tail -5 | \
            sed 's/^/  /'
    fi

    echo ""
}

# ============================================================
# COMPARISON ANALYSIS
# ============================================================

compare_logs() {
    local file1=$1
    local file2=$2

    print_header "Comparing: $(basename $file1) vs $(basename $file2)"

    local count1=$(wc -l < "$file1")
    local count2=$(wc -l < "$file2")
    local diff=$((count2 - count1))

    echo "File 1 lines: $count1"
    echo "File 2 lines: $count2"
    echo "Difference: $diff ($(echo "scale=1; $diff * 100 / $count1" | bc)%)"
}

# ============================================================
# HOURLY SUMMARY
# ============================================================

hourly_summary() {
    local logfile=$1

    print_header "Hourly Event Distribution"
    awk '{
        timestamp = substr($1, 1, 13)
        events[timestamp]++
    }
    END {
        for (ts in events) {
            printf "%s:00 - %s:59: %4d events\n", ts, ts, events[ts]
        }
    }' "$logfile" | sort
}

# ============================================================
# MAIN
# ============================================================

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <logfile> [error_pattern] [warn_pattern]"
    echo "Example: $0 /var/log/syslog 'ERROR|CRITICAL' 'WARN'"
    exit 1
fi

logfile=$1
error_pattern=${2:-"ERROR|CRITICAL|FATAL"}
warn_pattern=${3:-"WARN|WARNING"}

analyze_log "$logfile" "$error_pattern" "$warn_pattern"
hourly_summary "$logfile"

echo ""
echo "✓ Analysis complete"
