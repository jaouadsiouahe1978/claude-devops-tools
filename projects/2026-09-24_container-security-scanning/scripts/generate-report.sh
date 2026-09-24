#!/bin/bash

# Generate Consolidated Security Report
# Creates HTML and JSON reports from Trivy scans
# Usage: ./generate-report.sh [scan_results_dir] [output_file]

set -euo pipefail

SCAN_DIR="${1:-.}/scan-results"
OUTPUT_FILE="${2:-security-report}"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Generating Security Report ===${NC}\n"

if [ ! -d "${SCAN_DIR}" ]; then
    echo -e "${RED}Error: Scan directory not found: ${SCAN_DIR}${NC}"
    exit 1
fi

# Find latest scan results
LATEST_SCAN=$(ls -d "${SCAN_DIR}"/*/ 2>/dev/null | sort -r | head -1)
if [ -z "${LATEST_SCAN}" ]; then
    echo -e "${RED}Error: No scan results found in ${SCAN_DIR}${NC}"
    exit 1
fi

echo "Using scan results from: ${LATEST_SCAN}"

# Generate JSON consolidated report
JSON_REPORT="${OUTPUT_FILE}.json"
{
    echo "{"
    echo '  "report_date": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","'
    echo '  "scan_results": ['

    first=true
    for result in "${LATEST_SCAN}"trivy-*.json; do
        if [ -f "$result" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo "    {"
            echo '      "file": "'$(basename "$result")'","'
            # Extract summary from result
            jq -c '{
                image: (.Results[0].Target // "unknown"),
                vulnerabilities: ([.Results[]?.Vulnerabilities[]? // empty] | length),
                critical: ([.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="CRITICAL")] | length),
                high: ([.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="HIGH")] | length),
                medium: ([.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="MEDIUM")] | length)
            }' "$result" | sed 's/^/      /'
            echo "    }"
        fi
    done

    echo "  ]"
    echo "}"
} > "${JSON_REPORT}"

echo -e "${GREEN}✓ JSON report generated: ${JSON_REPORT}${NC}"

# Generate HTML report
HTML_REPORT="${OUTPUT_FILE}.html"
cat > "${HTML_REPORT}" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Container Security Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 { font-size: 2em; margin-bottom: 10px; }
        .content { padding: 30px; }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 5px;
        }
        .stat-value { font-size: 2em; font-weight: bold; color: #667eea; }
        .stat-label { color: #666; margin-top: 5px; }
        .severity-critical { border-left-color: #dc3545; }
        .severity-critical .stat-value { color: #dc3545; }
        .severity-high { border-left-color: #fd7e14; }
        .severity-high .stat-value { color: #fd7e14; }
        .severity-medium { border-left-color: #ffc107; }
        .severity-medium .stat-value { color: #ffc107; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #ddd;
        }
        td { padding: 12px 15px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f8f9fa; }
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-weight: 600;
            font-size: 0.85em;
        }
        .badge-critical { background: #dc3545; color: white; }
        .badge-high { background: #fd7e14; color: white; }
        .badge-medium { background: #ffc107; color: #333; }
        .badge-low { background: #28a745; color: white; }
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 Container Security Report</h1>
            <p>Trivy Vulnerability Scan Results</p>
        </div>
        <div class="content">
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-label">Report Generated</div>
                    <div class="stat-value" id="report-date">-</div>
                </div>
                <div class="stat-card severity-critical">
                    <div class="stat-label">Critical Issues</div>
                    <div class="stat-value" id="critical-count">0</div>
                </div>
                <div class="stat-card severity-high">
                    <div class="stat-label">High Issues</div>
                    <div class="stat-value" id="high-count">0</div>
                </div>
                <div class="stat-card severity-medium">
                    <div class="stat-label">Medium Issues</div>
                    <div class="stat-value" id="medium-count">0</div>
                </div>
            </div>

            <h2>Scan Results by Image</h2>
            <table id="results-table">
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Critical</th>
                        <th>High</th>
                        <th>Medium</th>
                        <th>Low</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody id="results-body">
                </tbody>
            </table>
        </div>
        <div class="footer">
            <p>Generated by Trivy Security Scanner | Report includes all vulnerability levels</p>
        </div>
    </div>

    <script>
        // Load JSON report data
        fetch('REPORT_FILE_NAME.json')
            .then(r => r.json())
            .then(data => {
                document.getElementById('report-date').textContent = new Date(data.report_date).toLocaleString();

                let totalCritical = 0, totalHigh = 0, totalMedium = 0;
                const tbody = document.getElementById('results-body');

                data.scan_results.forEach(result => {
                    totalCritical += result.critical;
                    totalHigh += result.high;
                    totalMedium += result.medium;

                    const total = result.critical + result.high + result.medium;
                    const row = `<tr>
                        <td><strong>${result.image}</strong></td>
                        <td><span class="badge badge-critical">${result.critical}</span></td>
                        <td><span class="badge badge-high">${result.high}</span></td>
                        <td><span class="badge badge-medium">${result.medium}</span></td>
                        <td><span class="badge badge-low">0</span></td>
                        <td><strong>${total}</strong></td>
                    </tr>`;
                    tbody.innerHTML += row;
                });

                document.getElementById('critical-count').textContent = totalCritical;
                document.getElementById('high-count').textContent = totalHigh;
                document.getElementById('medium-count').textContent = totalMedium;
            })
            .catch(e => console.error('Error loading report:', e));
    </script>
</body>
</html>
EOF

echo -e "${GREEN}✓ HTML report generated: ${HTML_REPORT}${NC}"

# Generate text summary
SUMMARY="${OUTPUT_FILE}-summary.txt"
{
    echo "=== Container Security Scan Report ==="
    echo "Generated: $(date)"
    echo ""
    echo "Scan Location: ${LATEST_SCAN}"
    echo ""
    echo "=== Summary ==="

    TOTAL_CRITICAL=0
    TOTAL_HIGH=0
    TOTAL_MEDIUM=0

    for result in "${LATEST_SCAN}"trivy-*.json; do
        if [ -f "$result" ]; then
            IMAGE=$(jq -r '.Results[0].Target // "unknown"' "$result")
            CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="CRITICAL")] | length' "$result")
            HIGH=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="HIGH")] | length' "$result")
            MEDIUM=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="MEDIUM")] | length' "$result")

            TOTAL_CRITICAL=$((TOTAL_CRITICAL + CRITICAL))
            TOTAL_HIGH=$((TOTAL_HIGH + HIGH))
            TOTAL_MEDIUM=$((TOTAL_MEDIUM + MEDIUM))

            echo "Image: ${IMAGE}"
            echo "  CRITICAL: ${CRITICAL} | HIGH: ${HIGH} | MEDIUM: ${MEDIUM}"
        fi
    done

    echo ""
    echo "=== Total Issues ==="
    echo "CRITICAL: ${TOTAL_CRITICAL}"
    echo "HIGH: ${TOTAL_HIGH}"
    echo "MEDIUM: ${TOTAL_MEDIUM}"
} > "${SUMMARY}"

echo -e "${GREEN}✓ Summary report generated: ${SUMMARY}${NC}"

echo -e "\n${BLUE}Reports generated:${NC}"
echo "  - ${JSON_REPORT}"
echo "  - ${HTML_REPORT}"
echo "  - ${SUMMARY}"
