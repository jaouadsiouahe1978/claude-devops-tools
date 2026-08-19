#!/bin/bash

# Helm Chart Installation and Testing Script
# This script demonstrates how to use the myapp Helm chart

set -e

CHART_DIR="./charts/myapp-chart"
RELEASE_NAME="myapp"
NAMESPACE="default"
ENVIRONMENT=${1:-dev}  # dev or prod

echo "========================================="
echo "Helm Chart Installation Script"
echo "========================================="
echo "Environment: $ENVIRONMENT"
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Helm is installed
print_step "Checking Helm installation..."
if ! command -v helm &> /dev/null; then
    print_error "Helm is not installed. Please install Helm 3."
    exit 1
fi
echo "Helm version: $(helm version --short)"
echo ""

# Check if kubectl is installed
print_step "Checking kubectl installation..."
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed."
    exit 1
fi
echo "kubectl version: $(kubectl version --short --client)"
echo ""

# Check if chart exists
print_step "Validating Helm chart..."
if [ ! -f "$CHART_DIR/Chart.yaml" ]; then
    print_error "Chart not found at $CHART_DIR/Chart.yaml"
    exit 1
fi
echo "Chart found: $(cat $CHART_DIR/Chart.yaml | grep -E '^name:|^version:')"
echo ""

# Lint the chart
print_step "Linting Helm chart..."
helm lint "$CHART_DIR"
echo ""

# Create namespace if it doesn't exist
print_step "Creating namespace if needed..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo "Namespace '$NAMESPACE' ready"
echo ""

# Show the templates that will be generated
print_step "Generating Kubernetes manifests (dry-run)..."
VALUES_FILE=""
if [ "$ENVIRONMENT" = "prod" ]; then
    VALUES_FILE="$CHART_DIR/values-prod.yaml"
    print_info "Using production values"
else
    VALUES_FILE="$CHART_DIR/values-dev.yaml"
    print_info "Using development values"
fi

helm template $RELEASE_NAME "$CHART_DIR" -f "$VALUES_FILE" > /tmp/helm-manifests.yaml
echo "Generated manifests saved to /tmp/helm-manifests.yaml"
echo ""

# Count resources
RESOURCE_COUNT=$(grep "^kind:" /tmp/helm-manifests.yaml | wc -l)
echo "Total resources to be created: $RESOURCE_COUNT"
echo ""

# Show first 50 lines of manifests for verification
print_step "Preview of generated manifests:"
head -50 /tmp/helm-manifests.yaml
echo "..."
echo ""

# Ask for confirmation before installing
read -p "Do you want to install the chart? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Installing Helm release..."

    if [ "$ENVIRONMENT" = "prod" ]; then
        helm install $RELEASE_NAME "$CHART_DIR" \
            -n $NAMESPACE \
            -f "$VALUES_FILE"
    else
        helm install $RELEASE_NAME "$CHART_DIR" \
            -n $NAMESPACE \
            -f "$VALUES_FILE"
    fi

    echo ""
    print_step "Installation complete!"
    echo ""

    # Show release status
    print_step "Release status:"
    helm status $RELEASE_NAME -n $NAMESPACE
    echo ""

    # Show deployed resources
    print_step "Deployed resources:"
    kubectl get all -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"
    echo ""

    # Show how to access the application
    print_step "Next steps:"
    echo "1. Watch pods starting: kubectl get pods -n $NAMESPACE -w"
    echo "2. View logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME"
    echo "3. Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-frontend 8080:80"
    echo "4. Check helm release: helm history $RELEASE_NAME -n $NAMESPACE"
    echo ""

    # Useful commands for debugging
    print_step "Useful debugging commands:"
    cat << 'EOF'
# Get deployment status
kubectl describe deployment -n default myapp-frontend

# View pod logs
kubectl logs -n default deployment/myapp-frontend

# Get events
kubectl get events -n default --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods -n default

# Edit a resource
kubectl edit deployment -n default myapp-frontend

# Scale a deployment
kubectl scale deployment -n default myapp-backend --replicas=3

# Upgrade the release
helm upgrade myapp ./charts/myapp-chart -n default

# Rollback to previous version
helm rollback myapp 1 -n default

# Delete the release
helm uninstall myapp -n default
EOF
    echo ""

else
    print_info "Installation cancelled."
    echo "You can view the manifests with:"
    echo "  helm template $RELEASE_NAME $CHART_DIR -f $VALUES_FILE"
    echo ""
    echo "To install manually later, run:"
    echo "  helm install $RELEASE_NAME $CHART_DIR -n $NAMESPACE -f $VALUES_FILE"
fi
