#!/bin/bash
set -e

NAMESPACE="devops-app"
RELEASE_NAME="devops-app"
CHART_PATH="../helm-chart"

echo "🔄 Upgrading Kubernetes Helm Release..."
echo "  Namespace: $NAMESPACE"
echo "  Release: $RELEASE_NAME"
echo ""

# Check if release exists
if ! helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "❌ Release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
    echo "   Run ./install.sh first"
    exit 1
fi

# Validate Helm chart
echo "📋 Validating Helm chart..."
helm lint $CHART_PATH

# Show current release
echo ""
echo "📊 Current release:"
helm status $RELEASE_NAME -n $NAMESPACE

# Dry run first
echo ""
echo "🧪 Running Helm upgrade in dry-run mode..."
helm upgrade $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --dry-run \
  --debug

# Ask for confirmation
echo ""
read -p "✅ Ready to upgrade? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Upgrade cancelled"
    exit 1
fi

# Upgrade the chart
echo "💫 Upgrading Helm chart..."
helm upgrade $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --wait \
  --timeout 5m

echo ""
echo "✨ Upgrade complete!"
echo ""
echo "📝 Release history:"
helm history $RELEASE_NAME -n $NAMESPACE
