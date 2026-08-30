#!/bin/bash
set -euo pipefail

ENV="${1:-dev}"
RELEASE_NAME="myapp-${ENV}"
CHART_PATH="./helm/myapp"
NAMESPACE="${ENV}"
ACTION="${2:-install}"

if [[ ! "$ENV" =~ ^(dev|prod)$ ]]; then
    echo "❌ Invalid environment: $ENV"
    exit 1
fi

VALUES_FILE="${CHART_PATH}/values-${ENV}.yaml"

echo "📦 Creating namespace $NAMESPACE..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 Deploying $RELEASE_NAME to $NAMESPACE..."
helm "${ACTION}" "$RELEASE_NAME" "$CHART_PATH" \
    -f "$VALUES_FILE" \
    -n "$NAMESPACE"

echo "✅ Deployment successful!"
echo ""
echo "📊 Pods:"
kubectl get pods -n "$NAMESPACE" -l "app=${RELEASE_NAME}"

echo ""
echo "💡 Next: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME} 5000:5000"
