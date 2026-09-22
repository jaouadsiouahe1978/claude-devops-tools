#!/bin/bash
# Upgrade Helm chart with new configuration or version

set -e

RELEASE_NAME="${1:-my-app}"
ENVIRONMENT="${2:-dev}"
CHART_PATH="../my-app-chart"

echo "🔄 Upgrading Helm chart: $RELEASE_NAME (environment: $ENVIRONMENT)"

if [ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ]; then
    echo "📦 Upgrading PRODUCTION environment..."
    helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
        -f "$CHART_PATH/values-prod.yaml" \
        -n production \
        --debug
else
    echo "📦 Upgrading DEV environment..."
    helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
        -f "$CHART_PATH/values-dev.yaml" \
        -n dev \
        --debug
fi

echo "✅ Upgrade complete!"
echo ""
echo "📊 View rollout status:"
echo "   kubectl rollout status deployment/my-app-backend -n $([ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ] && echo "production" || echo "dev")"
echo "   kubectl rollout status deployment/my-app-frontend -n $([ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ] && echo "production" || echo "dev")"
