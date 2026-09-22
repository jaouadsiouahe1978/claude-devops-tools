#!/bin/bash
# Uninstall Helm chart

set -e

RELEASE_NAME="${1:-my-app}"
ENVIRONMENT="${2:-dev}"

echo "🗑️  Uninstalling Helm chart: $RELEASE_NAME (environment: $ENVIRONMENT)"

if [ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ]; then
    NAMESPACE="production"
else
    NAMESPACE="dev"
fi

echo "⚠️  This will delete all resources for $RELEASE_NAME in namespace $NAMESPACE"
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --debug
    echo "✅ Uninstallation complete!"
else
    echo "❌ Cancelled"
    exit 1
fi
