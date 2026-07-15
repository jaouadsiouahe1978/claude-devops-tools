#!/bin/bash

# log-analyzer.sh - Parse and analyze log files for patterns
# Usage: ./log-analyzer.sh <log_file> <pattern> [context_lines]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_ROOT}/logs/monitor.log"

usage() {
    cat <<EOF
Usage: $0 <log_file> <pattern> [options]

Arguments:
  log_file          Path to log file to analyze
  pattern           Pattern/keyword to search for (case-insensitive)

Options:
  -c, --context N   Show N lines of context (default: 2)
  -e, --errors      Show only error lines
  -w, --warnings    Show only warning lines
  -s, --stats       Show statistics only
  -h, --help        Show this help message

Examples:
  $0 /var/log/syslog "error"
  $0 /var/log/auth.log "failed" --context 3
  $0 /var/log/apache2/error.log --errors --stats
EOF
    exit 1
}

log_action() {
    local action="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $action" >> "$LOG_FILE"
}

analyze_log() {
    local log_file="$1"
    local pattern="$2"
    local context=${3:-2}
    local show_stats=false
    local filter_type="none"

    # Parse additional options
    shift 2
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--context)
                context="$2"
                shift 2
                ;;
            -e|--errors)
                filter_type="errors"
                shift
                ;;
            -w|--warnings)
                filter_type="warnings"
                shift
                ;;
            -s|--stats)
                show_stats=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage
                ;;
        esac
    done

    # Check if log file exists
    if [[ ! -f "$log_file" ]]; then
        echo "Error: Log file not found: $log_file" >&2
        log_action "ERROR: Log file not found: $log_file"
        exit 1
    fi

    echo "========================================"
    echo "LOG ANALYSIS: $(basename "$log_file")"
    echo "Pattern: $pattern | Context: $context lines"
    echo "========================================"

    # Determine grep filter
    local grep_pattern="$pattern"
    case "$filter_type" in
        errors)
            grep_pattern="(error|critical|failed|exception)"
            ;;
        warnings)
            grep_pattern="(warning|warn|deprecated)"
            ;;
    esac

    # Search and display matches
    local match_count=0
    if grep -qi "$grep_pattern" "$log_file"; then
        match_count=$(grep -ci "$grep_pattern" "$log_file")
        echo ""
        echo "Found $match_count matching lines:"
        echo "----------------------------------------"
        grep -i -C "$context" "$grep_pattern" "$log_file" | head -50
        echo "----------------------------------------"
    else
        echo "No matches found for pattern: $pattern"
    fi

    # Show statistics if requested
    if [[ "$show_stats" == true ]]; then
        show_statistics "$log_file" "$grep_pattern" "$match_count"
    fi

    log_action "Analyzed $log_file for pattern '$pattern' (found: $match_count)"
}

show_statistics() {
    local log_file="$1"
    local pattern="$2"
    local match_count="$3"

    echo ""
    echo "STATISTICS:"
    echo "----------------------------------------"
    echo "Total matches: $match_count"
    echo "File size: $(du -h "$log_file" | awk '{print $1}')"
    echo "Line count: $(wc -l < "$log_file")"
    echo "Match percentage: $(echo "scale=2; ($match_count * 100) / $(wc -l < "$log_file")" | bc)%"

    # Show hourly distribution (if timestamps are present)
    if grep -q '[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}' "$log_file"; then
        echo ""
        echo "Hourly distribution of matches:"
        grep -i "$pattern" "$log_file" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}' | cut -d: -f1 | sort | uniq -c
    fi

    # Show top sources (if IP addresses present)
    if grep -qE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$log_file"; then
        echo ""
        echo "Top IP addresses in matches:"
        grep -i "$pattern" "$log_file" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq -c | sort -rn | head -5
    fi
}

main() {
    if [[ $# -lt 2 ]]; then
        usage
    fi

    analyze_log "$@"
}

main "$@"
