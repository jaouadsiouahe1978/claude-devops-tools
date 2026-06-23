#!/bin/bash
set -e

NAMESPACE="devops-app"
RELEASE_NAME="devops-app"

echo "🔙 Rolling back Kubernetes Helm Release..."
echo "  Namespace: $NAMESPACE"
echo "  Release: $RELEASE_NAME"
echo ""

# Check if release exists
if ! helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "❌ Release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
    exit 1
fi

# Show release history
echo "📋 Release history:"
helm history $RELEASE_NAME -n $NAMESPACE

echo ""
read -p "Enter the revision to rollback to (or press Enter for previous): " REVISION

if [ -z "$REVISION" ]; then
    echo "🔄 Rolling back to previous revision..."
    helm rollback $RELEASE_NAME -n $NAMESPACE --wait --timeout 5m
else
    echo "🔄 Rolling back to revision $REVISION..."
    helm rollback $RELEASE_NAME $REVISION -n $NAMESPACE --wait --timeout 5m
fi

echo ""
echo "✨ Rollback complete!"
echo ""
echo "📊 Current status:"
helm status $RELEASE_NAME -n $NAMESPACE
