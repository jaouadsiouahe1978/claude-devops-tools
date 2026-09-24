#!/bin/bash

# Vulnerability Severity Checker
# Checks if an image has vulnerabilities at or above a severity threshold
# Usage: ./check-vulnerabilities.sh <image> [severity] [max_allowed]

set -euo pipefail

IMAGE="${1:?Error: Image name required}"
SEVERITY="${2:-HIGH}"
MAX_ALLOWED="${3:-0}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Vulnerability Check ===${NC}"
echo "Image: ${IMAGE}"
echo "Checking for: ${SEVERITY} and above"
echo "Max allowed: ${MAX_ALLOWED}"
echo ""

# Scan image
TEMP_REPORT=$(mktemp)
trap "rm -f ${TEMP_REPORT}" EXIT

if ! trivy image --format json --output "${TEMP_REPORT}" "${IMAGE}" 2>/dev/null; then
    echo -e "${RED}✗ Failed to scan image${NC}"
    exit 1
fi

# Count vulnerabilities by severity
CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="CRITICAL")] | length' "${TEMP_REPORT}")
HIGH=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="HIGH")] | length' "${TEMP_REPORT}")
MEDIUM=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="MEDIUM")] | length' "${TEMP_REPORT}")

echo "Vulnerabilities found:"
echo "  CRITICAL: ${CRITICAL}"
echo "  HIGH: ${HIGH}"
echo "  MEDIUM: ${MEDIUM}"
echo ""

# Determine if check passes
VIOLATIONS=0
case "${SEVERITY}" in
    CRITICAL)
        VIOLATIONS=${CRITICAL}
        ;;
    HIGH)
        VIOLATIONS=$((CRITICAL + HIGH))
        ;;
    MEDIUM)
        VIOLATIONS=$((CRITICAL + HIGH + MEDIUM))
        ;;
    *)
        echo -e "${RED}Error: Unknown severity level${NC}"
        exit 1
        ;;
esac

if [ "${VIOLATIONS}" -gt "${MAX_ALLOWED}" ]; then
    echo -e "${RED}✗ Check FAILED: ${VIOLATIONS} vulnerabilities found (max allowed: ${MAX_ALLOWED})${NC}"

    # Print details
    echo -e "\n${YELLOW}Vulnerable packages:${NC}"
    jq -r '.Results[]? | select(.Vulnerabilities) | .Target as $target | .Vulnerabilities[] | select(.Severity=="CRITICAL" or .Severity=="HIGH") | "  [\(.Severity)] \($target): \(.VulnerabilityID) - \(.Title // "N/A")"' "${TEMP_REPORT}" | head -10

    exit 1
else
    echo -e "${GREEN}✓ Check PASSED: ${VIOLATIONS} vulnerabilities found (max allowed: ${MAX_ALLOWED})${NC}"
    exit 0
fi
