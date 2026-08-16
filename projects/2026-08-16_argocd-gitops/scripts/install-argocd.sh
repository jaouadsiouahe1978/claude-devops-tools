#!/bin/bash
#
# ArgoCD Installation & Setup Script
# Automates the installation and basic configuration of ArgoCD
#

set -e

echo "🚀 ArgoCD Installation Script"
echo "=============================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Step 1: Check prerequisites
log_info "Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    log_error "kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command -v git &> /dev/null; then
    log_error "git not found. Please install git first."
    exit 1
fi

log_success "Prerequisites verified!"
echo ""

# Step 2: Verify Kubernetes cluster
log_info "Verifying Kubernetes cluster..."

if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster. Please configure kubectl."
    exit 1
fi

CLUSTER_NAME=$(kubectl config current-context)
log_success "Connected to cluster: $CLUSTER_NAME"
echo ""

# Step 3: Create namespace
log_info "Creating 'argocd' namespace..."

if kubectl get namespace argocd &> /dev/null; then
    log_warning "Namespace 'argocd' already exists"
else
    kubectl create namespace argocd
    log_success "Namespace 'argocd' created"
fi
echo ""

# Step 4: Install ArgoCD
log_info "Installing ArgoCD..."

ARGOCD_VERSION="stable"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

log_info "Downloading ArgoCD manifests from $MANIFEST_URL..."
if kubectl apply -n argocd -f $MANIFEST_URL; then
    log_success "ArgoCD manifests applied successfully"
else
    log_error "Failed to apply ArgoCD manifests"
    exit 1
fi
echo ""

# Step 5: Wait for ArgoCD to be ready
log_info "Waiting for ArgoCD pods to be ready..."

kubectl rollout status deployment/argocd-server -n argocd --timeout=300s || {
    log_warning "ArgoCD didn't become ready within timeout"
    log_info "Checking pod status..."
    kubectl get pods -n argocd
}

log_success "ArgoCD installation complete!"
echo ""

# Step 6: Get initial admin password
log_info "Retrieving initial admin password..."

ATTEMPTS=0
MAX_ATTEMPTS=30
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; then
        ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        log_success "Initial admin password retrieved"
        break
    else
        ATTEMPTS=$((ATTEMPTS + 1))
        if [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; then
            echo -n "."
            sleep 1
        fi
    fi
done

if [ -z "$ADMIN_PASSWORD" ]; then
    log_error "Could not retrieve admin password. Try again later."
else
    echo ""
    echo -e "${GREEN}=== ArgoCD Credentials ===${NC}"
    echo "Username: admin"
    echo "Password: $ADMIN_PASSWORD"
    echo ""
fi

# Step 7: Display access information
echo -e "${GREEN}=== ArgoCD Access Info ===${NC}"
echo "Namespace: argocd"
echo ""
echo "Via kubectl port-forward:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then access: https://localhost:8080"
echo ""

# Step 8: Show next steps
echo -e "${BLUE}=== Next Steps ===${NC}"
echo ""
echo "1. Port-forward to access the UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "2. Install ArgoCD CLI (optional):"
echo "   curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "   chmod +x argocd"
echo "   sudo mv argocd /usr/local/bin/"
echo ""
echo "3. Configure your Git repository:"
echo "   argocd repo add <repo-url> --username <git-user> --password <git-token>"
echo ""
echo "4. Create an ArgoCD Application:"
echo "   argocd app create <app-name> --repo <repo-url> --path <path> --dest-server https://kubernetes.default.svc --dest-namespace default"
echo ""
echo "5. Enable auto-sync (optional):"
echo "   argocd app set <app-name> --sync-policy automated"
echo ""

log_success "Installation complete! Happy GitOps! 🎉"
