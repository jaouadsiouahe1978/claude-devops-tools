#!/bin/bash

# Report Generator
# Generates daily/custom log reports

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/monitoring.conf"
REPORT_DATE=${1:-$(date '+%Y-%m-%d')}
REPORT_FORMAT=${2:-csv}

source "$CONFIG_FILE"

# ============================================================
# FUNCTIONS
# ============================================================

generate_csv_report() {
    local output_file="${REPORT_OUTPUT_DIR}/report-${REPORT_DATE}.csv"

    {
        echo "timestamp,severity,message"
        grep "^\\[$REPORT_DATE" "$ALERT_LOG_FILE" 2>/dev/null | \
            awk -F'[][]' '{
                print $2","$4","$6
            }'
    } > "$output_file"

    echo "CSV Report: $output_file"
}

generate_text_report() {
    local output_file="${REPORT_OUTPUT_DIR}/report-${REPORT_DATE}.txt"

    {
        echo "═══════════════════════════════════════════════════════"
        echo "Log Monitoring Report - $REPORT_DATE"
        echo "═══════════════════════════════════════════════════════"
        echo ""
        echo "SUMMARY:"
        grep "^\\[$REPORT_DATE" "$ALERT_LOG_FILE" 2>/dev/null | wc -l | \
            awk '{print "  Total Alerts: " $1}'

        echo ""
        echo "BY SEVERITY:"
        grep "^\\[$REPORT_DATE" "$ALERT_LOG_FILE" 2>/dev/null | \
            awk -F'[][]' '{print $4}' | sort | uniq -c | \
            awk '{printf "  %s: %d\n", $2, $1}'

        echo ""
        echo "DETAILS:"
        grep "^\\[$REPORT_DATE" "$ALERT_LOG_FILE" 2>/dev/null | head -20

        echo ""
        echo "═══════════════════════════════════════════════════════"
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    } > "$output_file"

    echo "Text Report: $output_file"
}

generate_json_report() {
    local output_file="${REPORT_OUTPUT_DIR}/report-${REPORT_DATE}.json"

    {
        echo "{"
        echo '  "date": "'$REPORT_DATE'",'
        echo '  "alerts": ['

        grep "^\\[$REPORT_DATE" "$ALERT_LOG_FILE" 2>/dev/null | \
            awk -F'[][]' '{
                gsub(/"/, "\\\"", $6)
                printf "    {\"timestamp\": \"%s\", \"severity\": \"%s\", \"message\": \"%s\"},\n", $2, $4, $6
            }' | sed '$ s/,$//'

        echo "  ]"
        echo "}"
    } > "$output_file"

    echo "JSON Report: $output_file"
}

# ============================================================
# MAIN
# ============================================================

mkdir -p "$REPORT_OUTPUT_DIR"

case "$REPORT_FORMAT" in
    csv)
        generate_csv_report
        ;;
    text|txt)
        generate_text_report
        ;;
    json)
        generate_json_report
        ;;
    all)
        generate_csv_report
        generate_text_report
        generate_json_report
        ;;
    *)
        echo "Usage: $0 [date] [format: csv|txt|json|all]"
        exit 1
        ;;
esac

echo "✓ Report generation complete"
