#!/bin/bash
set -e

NAMESPACE="devops-app"
RELEASE_NAME="devops-app"

echo "🗑️  Cleaning up Kubernetes Helm Release..."
echo "  Namespace: $NAMESPACE"
echo "  Release: $RELEASE_NAME"
echo ""

# Ask for confirmation
read -p "⚠️  Are you sure? This will delete all resources. (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

# Check if release exists
if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "🗑️  Uninstalling Helm release..."
    helm uninstall $RELEASE_NAME -n $NAMESPACE --wait
else
    echo "⚠️  Release '$RELEASE_NAME' not found"
fi

# Ask if we should delete the namespace
echo ""
read -p "Delete namespace '$NAMESPACE'? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting namespace..."
    kubectl delete namespace $NAMESPACE --wait
fi

echo ""
echo "✨ Cleanup complete!"
