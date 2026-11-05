#!/bin/bash
set -e

IMAGE_NAME="${1:-secure-app:latest}"
REPORT_FILE="${2:-trivy-report.json}"

echo "🔍 Scanning Docker image: $IMAGE_NAME"
echo "=================================="

if ! command -v trivy &> /dev/null; then
    echo "❌ Trivy not found. Install it with:"
    echo "   curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
    exit 1
fi

echo "📦 Running Trivy scan..."
trivy image --format json --output "$REPORT_FILE" "$IMAGE_NAME"

echo ""
echo "📊 Scan Summary:"
echo "=================================="

CRITICAL=$(jq '[.Results[].Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$REPORT_FILE" 2>/dev/null || echo "0")
HIGH=$(jq '[.Results[].Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$REPORT_FILE" 2>/dev/null || echo "0")
MEDIUM=$(jq '[.Results[].Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$REPORT_FILE" 2>/dev/null || echo "0")

echo "🔴 CRITICAL: $CRITICAL"
echo "🟠 HIGH:     $HIGH"
echo "🟡 MEDIUM:   $MEDIUM"

echo ""
if [ "$CRITICAL" -eq 0 ]; then
    echo "✅ No CRITICAL vulnerabilities found!"
else
    echo "❌ CRITICAL vulnerabilities detected!"
    jq '.Results[].Vulnerabilities[] | select(.Severity=="CRITICAL") | {ID, Title}' "$REPORT_FILE"
fi

echo ""
echo "📄 Full report saved to: $REPORT_FILE"
