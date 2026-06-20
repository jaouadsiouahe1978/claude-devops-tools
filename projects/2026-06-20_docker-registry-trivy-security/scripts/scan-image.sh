#!/bin/bash

# Scan Docker image with Trivy
# Usage: ./scan-image.sh <image_name:tag> [--severity CRITICAL,HIGH]

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <image_name:tag> [--severity CRITICAL,HIGH] [--format json|table|sarif]"
    echo ""
    echo "Examples:"
    echo "  $0 localhost:5000/myproject/app:v1"
    echo "  $0 ubuntu:22.04 --severity CRITICAL,HIGH"
    echo "  $0 myapp:latest --format json"
    exit 1
fi

IMAGE="$1"
SEVERITY="${2:-CRITICAL,HIGH,MEDIUM}"
FORMAT="${3:-table}"

# If second argument looks like severity
if [[ "$2" == --severity* ]]; then
    SEVERITY="${2#--severity }"
    if [ -n "$3" ] && [[ "$3" == --format* ]]; then
        FORMAT="${3#--format }"
    fi
fi

# If second argument looks like format
if [[ "$2" == --format* ]]; then
    FORMAT="${2#--format }"
fi

echo "🔍 Scanning image: $IMAGE"
echo "   Severity filter: $SEVERITY"
echo "   Format: $FORMAT"
echo ""

TRIVY_OPTS=(
    "image"
    "--severity" "$SEVERITY"
    "--format" "$FORMAT"
    "--exit-code" "0"
)

# Add output file for json/sarif
if [ "$FORMAT" = "json" ]; then
    OUTPUT_FILE="${IMAGE//:/_}.json"
    TRIVY_OPTS+=("--output" "$OUTPUT_FILE")
    echo "📝 Output will be saved to: $OUTPUT_FILE"
elif [ "$FORMAT" = "sarif" ]; then
    OUTPUT_FILE="${IMAGE//:/_}.sarif"
    TRIVY_OPTS+=("--output" "$OUTPUT_FILE")
    echo "📝 Output will be saved to: $OUTPUT_FILE"
fi

TRIVY_OPTS+=("$IMAGE")

# Run Trivy
trivy "${TRIVY_OPTS[@]}"

RESULT=$?

echo ""
echo "================================"
if [ $RESULT -eq 0 ]; then
    echo "✅ Scan completed"
else
    echo "⚠️  Scan found vulnerabilities"
fi
echo "================================"

# Print SBOM if available
if [ "$FORMAT" = "json" ] && [ -f "$OUTPUT_FILE" ]; then
    echo ""
    echo "📊 Summary from JSON output:"
    cat "$OUTPUT_FILE" | jq '.Results[0].Vulnerabilities | group_by(.Severity) | map({severity: .[0].Severity, count: length}) | sort_by(.count) | reverse[]' 2>/dev/null || true
fi

exit $RESULT
