#!/bin/bash
# Validate Helm chart syntax and structure

set -e

CHART_PATH="../my-app-chart"

echo "🔍 Validating Helm chart: $CHART_PATH"
echo ""

# Check Chart.yaml
echo "✓ Checking Chart.yaml..."
if [ ! -f "$CHART_PATH/Chart.yaml" ]; then
    echo "❌ Chart.yaml not found!"
    exit 1
fi

# Check values.yaml
echo "✓ Checking values.yaml..."
if [ ! -f "$CHART_PATH/values.yaml" ]; then
    echo "❌ values.yaml not found!"
    exit 1
fi

# Lint chart
echo "✓ Running helm lint..."
helm lint "$CHART_PATH" --strict

# Template validation
echo "✓ Validating templates..."
helm template my-release "$CHART_PATH" > /dev/null || {
    echo "❌ Template validation failed!"
    exit 1
}

# Dry-run for dev
echo "✓ Dry-run for DEV environment..."
helm install my-release-test "$CHART_PATH" \
    -f "$CHART_PATH/values-dev.yaml" \
    --dry-run \
    --debug \
    -n dev \
    --create-namespace > /dev/null || {
    echo "❌ Dry-run failed!"
    exit 1
}

# Dry-run for prod
echo "✓ Dry-run for PROD environment..."
helm install my-release-test "$CHART_PATH" \
    -f "$CHART_PATH/values-prod.yaml" \
    --dry-run \
    --debug \
    -n production \
    --create-namespace > /dev/null || {
    echo "❌ Dry-run failed!"
    exit 1
}

echo ""
echo "✅ All validations passed!"
echo ""
echo "Chart structure:"
tree -L 2 "$CHART_PATH" 2>/dev/null || find "$CHART_PATH" -type f | head -20
