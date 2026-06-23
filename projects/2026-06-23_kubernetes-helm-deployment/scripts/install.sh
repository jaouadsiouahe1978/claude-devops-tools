#!/bin/bash
set -e

NAMESPACE="devops-app"
RELEASE_NAME="devops-app"
CHART_PATH="../helm-chart"

echo "🚀 Installing Kubernetes Helm Chart..."
echo "  Namespace: $NAMESPACE"
echo "  Release: $RELEASE_NAME"
echo ""

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Validate Helm chart
echo "📋 Validating Helm chart..."
helm lint $CHART_PATH

# Dry run first
echo "🧪 Running Helm install in dry-run mode..."
helm install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --dry-run \
  --debug

# Ask for confirmation
echo ""
read -p "✅ Ready to install? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Installation cancelled"
    exit 1
fi

# Install the chart
echo "💫 Installing Helm chart..."
helm install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --wait \
  --timeout 5m

echo ""
echo "✨ Installation complete!"
echo ""
echo "📊 Check deployment status:"
echo "   kubectl get all -n $NAMESPACE"
echo ""
echo "📝 Check pod logs:"
echo "   kubectl logs -f deploy/devops-app-api -n $NAMESPACE"
echo ""
echo "🔗 Port-forward to API:"
echo "   kubectl port-forward svc/api-service 8080:80 -n $NAMESPACE"
