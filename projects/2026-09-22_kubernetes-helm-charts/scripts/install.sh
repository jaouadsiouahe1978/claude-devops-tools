#!/bin/bash
# Install Helm chart for development or production

set -e

RELEASE_NAME="${1:-my-app}"
ENVIRONMENT="${2:-dev}"
CHART_PATH="../my-app-chart"

echo "🚀 Installing Helm chart: $RELEASE_NAME (environment: $ENVIRONMENT)"

if [ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ]; then
    echo "📦 Deploying to PRODUCTION environment..."
    helm install "$RELEASE_NAME" "$CHART_PATH" \
        -f "$CHART_PATH/values-prod.yaml" \
        -n production \
        --create-namespace \
        --debug
else
    echo "📦 Deploying to DEV environment..."
    helm install "$RELEASE_NAME" "$CHART_PATH" \
        -f "$CHART_PATH/values-dev.yaml" \
        -n dev \
        --create-namespace \
        --debug
fi

echo "✅ Installation complete!"
echo ""
echo "📊 To view deployment status:"
echo "   kubectl get all -n $([ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ] && echo "production" || echo "dev")"
echo ""
echo "📋 To view Helm release:"
echo "   helm list -n $([ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "production" ] && echo "production" || echo "dev")"
