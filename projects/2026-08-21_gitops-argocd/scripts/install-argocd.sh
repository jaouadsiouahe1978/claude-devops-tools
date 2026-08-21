#!/bin/bash

# ArgoCD Installation Script
# Installs and configures ArgoCD on a Kubernetes cluster
# Usage: bash install-argocd.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="argocd"
VERSION="v2.8.0"
WAIT_TIME=300
EXPOSE_UI="true"
UI_PORT=8080

# Functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

usage() {
    cat << EOF
ArgoCD Installation Script

Usage: $0 [options]

Options:
    -n, --namespace NAMESPACE     Namespace for ArgoCD (default: argocd)
    -v, --version VERSION         ArgoCD version (default: v2.8.0)
    -w, --wait-time SECONDS       Wait time for deployment (default: 300)
    --expose-ui                   Expose UI via port-forward (default: true)
    --ui-port PORT                Port for UI (default: 8080)
    -h, --help                    Show this help message

Examples:
    # Install with defaults
    bash $0

    # Install in custom namespace
    bash $0 -n my-argocd

    # Install specific version
    bash $0 -v v2.7.0

    # Install without exposing UI
    bash $0 --expose-ui=false

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -w|--wait-time)
            WAIT_TIME="$2"
            shift 2
            ;;
        --expose-ui)
            EXPOSE_UI="$2"
            shift 2
            ;;
        --ui-port)
            UI_PORT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Main installation
main() {
    print_header "ArgoCD Installation"

    # Check prerequisites
    print_header "Checking prerequisites"

    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    print_success "kubectl found"

    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"

    # Create namespace
    print_header "Creating namespace"
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_warning "Namespace $NAMESPACE already exists"
    else
        kubectl create namespace "$NAMESPACE"
        print_success "Namespace $NAMESPACE created"
    fi

    # Label namespace
    kubectl label namespace "$NAMESPACE" app.kubernetes.io/name=argocd --overwrite

    # Install ArgoCD
    print_header "Installing ArgoCD $VERSION"

    ARGOCD_URL="https://raw.githubusercontent.com/argoproj/argo-cd/$VERSION/manifests/install.yaml"

    if kubectl apply -n "$NAMESPACE" -f "$ARGOCD_URL"; then
        print_success "ArgoCD manifests applied"
    else
        print_error "Failed to apply ArgoCD manifests"
        exit 1
    fi

    # Wait for deployment
    print_header "Waiting for ArgoCD deployment"
    echo "Waiting up to ${WAIT_TIME}s for ArgoCD components to be ready..."

    # Wait for server
    if ! kubectl wait -n "$NAMESPACE" --for=condition=Ready pod \
        -l app.kubernetes.io/name=argocd-server --timeout="${WAIT_TIME}s" 2>/dev/null; then
        print_warning "Server pod did not become ready"
    else
        print_success "ArgoCD server is ready"
    fi

    # Wait for repo server
    if ! kubectl wait -n "$NAMESPACE" --for=condition=Ready pod \
        -l app.kubernetes.io/name=argocd-repo-server --timeout="${WAIT_TIME}s" 2>/dev/null; then
        print_warning "Repository server did not become ready"
    else
        print_success "ArgoCD repository server is ready"
    fi

    # Wait for controller
    if ! kubectl wait -n "$NAMESPACE" --for=condition=Ready pod \
        -l app.kubernetes.io/name=argocd-application-controller --timeout="${WAIT_TIME}s" 2>/dev/null; then
        print_warning "Application controller did not become ready"
    else
        print_success "ArgoCD application controller is ready"
    fi

    # Get initial password
    print_header "Getting initial credentials"

    if kubectl get secret -n "$NAMESPACE" argocd-initial-admin-secret &> /dev/null; then
        INITIAL_PASSWORD=$(kubectl -n "$NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
        print_success "Initial password retrieved"
        echo -e "${YELLOW}Username: admin${NC}"
        echo -e "${YELLOW}Password: $INITIAL_PASSWORD${NC}"
    else
        print_warning "Could not retrieve initial password"
    fi

    # Show services
    print_header "ArgoCD Services"
    kubectl get svc -n "$NAMESPACE" -l app.kubernetes.io/part-of=argocd

    # Show pods
    print_header "ArgoCD Pods"
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/part-of=argocd

    # Expose UI
    if [ "$EXPOSE_UI" = "true" ]; then
        print_header "Exposing ArgoCD UI"
        echo "Starting port-forward on localhost:$UI_PORT..."
        echo "URL: https://localhost:$UI_PORT"

        # Kill any existing port-forward on the same port
        pkill -f "port-forward.*$UI_PORT" || true

        # Start port-forward in background
        kubectl port-forward svc/argocd-server -n "$NAMESPACE" "$UI_PORT":443 &
        PF_PID=$!

        # Wait for port-forward to be ready
        sleep 2

        if kill -0 $PF_PID 2>/dev/null; then
            print_success "Port-forward started (PID: $PF_PID)"
            echo "To stop port-forward: kill $PF_PID"
        else
            print_error "Failed to start port-forward"
        fi
    fi

    print_header "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Access ArgoCD UI at https://localhost:$UI_PORT"
    echo "2. Login with username 'admin' and the password shown above"
    echo "3. Add your Git repository: argocd repo add https://github.com/your-repo --username=your-user --password=your-token"
    echo "4. Create an application: kubectl apply -f applications/guestbook-app.yaml"
    echo ""
    echo "Useful commands:"
    echo "  kubectl get applications -n $NAMESPACE"
    echo "  kubectl describe application guestbook -n $NAMESPACE"
    echo "  argocd app list"
    echo "  argocd app get guestbook"
    echo ""
}

main
