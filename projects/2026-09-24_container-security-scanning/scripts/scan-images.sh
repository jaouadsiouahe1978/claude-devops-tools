#!/bin/bash

# Container Security Scanning Script
# Scans multiple Docker images for vulnerabilities using Trivy
# Usage: ./scan-images.sh [images_file] [output_dir]

set -euo pipefail

IMAGES_FILE="${1:-test-images.txt}"
OUTPUT_DIR="${2:-.}/scan-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="${OUTPUT_DIR}/${TIMESTAMP}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create output directory
mkdir -p "${REPORT_DIR}"

echo -e "${BLUE}=== Container Security Scanning with Trivy ===${NC}"
echo -e "${BLUE}Report directory: ${REPORT_DIR}${NC}\n"

# Check if Trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${RED}Error: Trivy is not installed${NC}"
    echo "Install Trivy: https://aquasecurity.github.io/trivy/"
    exit 1
fi

# Check if images file exists
if [ ! -f "${IMAGES_FILE}" ]; then
    echo -e "${RED}Error: Images file not found: ${IMAGES_FILE}${NC}"
    exit 1
fi

# Initialize summary
TOTAL_IMAGES=0
SCANNED_IMAGES=0
CRITICAL_FOUND=0
HIGH_FOUND=0
FAILED_SCANS=0

declare -A results

# Scan each image
echo -e "${YELLOW}Starting image scans...${NC}\n"

while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    IMAGE="$line"
    TOTAL_IMAGES=$((TOTAL_IMAGES + 1))

    IMAGE_NAME=$(echo "$IMAGE" | sed 's/:/_/g' | sed 's|/|_|g')
    REPORT_FILE="${REPORT_DIR}/trivy-${IMAGE_NAME}.json"

    echo -e "${BLUE}[${TOTAL_IMAGES}] Scanning: ${IMAGE}${NC}"

    # Scan image
    if trivy image \
        --format json \
        --output "${REPORT_FILE}" \
        --severity CRITICAL,HIGH,MEDIUM,LOW \
        "${IMAGE}" 2>/dev/null; then

        SCANNED_IMAGES=$((SCANNED_IMAGES + 1))

        # Count vulnerabilities
        CRITICAL=$(jq '[.Results[]?.Misconfigurations[]? // empty | select(.Severity=="CRITICAL")] | length' "${REPORT_FILE}" 2>/dev/null || echo 0)
        HIGH=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="HIGH")] | length' "${REPORT_FILE}" 2>/dev/null || echo 0)
        MEDIUM=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="MEDIUM")] | length' "${REPORT_FILE}" 2>/dev/null || echo 0)

        CRITICAL_FOUND=$((CRITICAL_FOUND + CRITICAL))
        HIGH_FOUND=$((HIGH_FOUND + HIGH))

        if [ "$CRITICAL" -gt 0 ]; then
            echo -e "  ${RED}✗ CRITICAL: ${CRITICAL}, HIGH: ${HIGH}, MEDIUM: ${MEDIUM}${NC}"
        elif [ "$HIGH" -gt 0 ]; then
            echo -e "  ${YELLOW}⚠ HIGH: ${HIGH}, MEDIUM: ${MEDIUM}${NC}"
        else
            echo -e "  ${GREEN}✓ Safe (${MEDIUM} medium/low issues)${NC}"
        fi
    else
        FAILED_SCANS=$((FAILED_SCANS + 1))
        echo -e "  ${RED}✗ Scan failed${NC}"
    fi

    echo ""
done < "${IMAGES_FILE}"

# Generate summary report
SUMMARY_FILE="${REPORT_DIR}/summary.txt"
{
    echo "=== Trivy Security Scan Summary ==="
    echo "Scan Date: $(date)"
    echo "Report Directory: ${REPORT_DIR}"
    echo ""
    echo "Results:"
    echo "  Total images scanned: ${TOTAL_IMAGES}"
    echo "  Successfully scanned: ${SCANNED_IMAGES}"
    echo "  Failed scans: ${FAILED_SCANS}"
    echo "  Total CRITICAL issues: ${CRITICAL_FOUND}"
    echo "  Total HIGH issues: ${HIGH_FOUND}"
    echo ""
    echo "Individual Results:"

    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        IMAGE="$line"
        IMAGE_NAME=$(echo "$IMAGE" | sed 's/:/_/g' | sed 's|/|_|g')
        REPORT_FILE="${REPORT_DIR}/trivy-${IMAGE_NAME}.json"

        if [ -f "${REPORT_FILE}" ]; then
            CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="CRITICAL")] | length' "${REPORT_FILE}" 2>/dev/null || echo 0)
            HIGH=$(jq '[.Results[]?.Vulnerabilities[]? // empty | select(.Severity=="HIGH")] | length' "${REPORT_FILE}" 2>/dev/null || echo 0)
            echo "  - ${IMAGE}: CRITICAL=${CRITICAL}, HIGH=${HIGH}"
        fi
    done < "${IMAGES_FILE}"
} > "${SUMMARY_FILE}"

cat "${SUMMARY_FILE}"

# Print table format for all images
echo -e "\n${BLUE}=== Detailed Scan Results ===${NC}\n"

for report in "${REPORT_DIR}"/trivy-*.json; do
    if [ -f "$report" ]; then
        echo -e "${YELLOW}$(basename "$report")${NC}"
        # Extract vulnerabilities in table format
        jq -r '.Results[]? | select(.Vulnerabilities) | .Target as $target | .Vulnerabilities[] | "\($target) | \(.Severity) | \(.VulnerabilityID) | \(.Title // "N/A")"' "$report" 2>/dev/null | column -t -s '|' || true
        echo ""
    fi
done

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
if [ "$FAILED_SCANS" -eq 0 ] && [ "$CRITICAL_FOUND" -eq 0 ] && [ "$HIGH_FOUND" -eq 0 ]; then
    echo -e "${GREEN}✓ All images passed security scan!${NC}"
    exit 0
elif [ "$CRITICAL_FOUND" -gt 0 ]; then
    echo -e "${RED}✗ ${CRITICAL_FOUND} CRITICAL vulnerabilities found!${NC}"
    exit 1
else
    echo -e "${YELLOW}⚠ ${HIGH_FOUND} HIGH vulnerabilities found${NC}"
    exit 0
fi
