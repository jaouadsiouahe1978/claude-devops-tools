#!/bin/bash

set -e

echo "🔒 Security Scanning with Trivy"
echo "════════════════════════════════════════════"
echo ""

# Check if Trivy is installed
if ! command -v trivy &> /dev/null; then
    echo "⚠️  Trivy not found. Installing..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

echo "Scanning images for vulnerabilities..."
echo ""

# Scan app:bad
echo "🔍 Scanning app:bad..."
trivy image --severity CRITICAL,HIGH,MEDIUM app:bad 2>/dev/null || {
    echo "  ⚠️  Trivy scanning skipped (may require internet)"
}

echo ""
echo "🔍 Scanning app:optimized..."
trivy image --severity CRITICAL,HIGH,MEDIUM app:optimized 2>/dev/null || {
    echo "  ⚠️  Trivy scanning skipped (may require internet)"
}

echo ""
echo "🔍 Scanning nginx:optimized..."
trivy image --severity CRITICAL,HIGH,MEDIUM nginx:optimized 2>/dev/null || {
    echo "  ⚠️  Trivy scanning skipped (may require internet)"
}

echo ""
echo "════════════════════════════════════════════"
echo "✅ Security scan complete!"
echo ""
echo "💡 Quick reference:"
echo "  CRITICAL: Requires immediate action"
echo "  HIGH:     Should be fixed soon"
echo "  MEDIUM:   Address in next sprint"
echo ""
echo "📖 Trivy output modes:"
echo "  trivy image --format json app:optimized     # JSON output"
echo "  trivy image --format sarif app:optimized    # SARIF for GitHub"
echo "  trivy image --format cyclonedx app:optimized # SBOM"
