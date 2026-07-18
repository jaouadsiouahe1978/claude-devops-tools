#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RELEASE_NAME="myapp"
NAMESPACE="default"
REVISION=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Rollback a Helm release

OPTIONS:
    -r, --release       Release name (default: myapp)
    -n, --namespace     Kubernetes namespace (default: default)
    --revision          Revision to rollback to (default: 0, previous)
    -h, --help          Show this help message

EXAMPLES:
    ./rollback.sh -r myapp -n production
    ./rollback.sh -r myapp -n production --revision 5

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --revision)
            REVISION="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if release exists
if ! helm get values "$RELEASE_NAME" -n "$NAMESPACE" &> /dev/null; then
    log_error "Release not found: $RELEASE_NAME in namespace $NAMESPACE"
    exit 1
fi

# Display release history
log_info "Release history for $RELEASE_NAME:"
helm history "$RELEASE_NAME" -n "$NAMESPACE"

log_info "Rolling back release: $RELEASE_NAME"

# Perform rollback
if [[ $REVISION -eq 0 ]]; then
    log_info "Rolling back to previous revision..."
    helm rollback "$RELEASE_NAME" -n "$NAMESPACE"
else
    log_info "Rolling back to revision: $REVISION"
    helm rollback "$RELEASE_NAME" "$REVISION" -n "$NAMESPACE"
fi

log_success "Rollback initiated"

# Wait for deployment rollout
log_info "Waiting for deployment to be ready..."
if kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m; then
    log_success "Deployment is ready"

    # Display status
    log_info "Deployment status:"
    kubectl get deployment "$RELEASE_NAME" -n "$NAMESPACE" -o wide

    log_info "Pods:"
    kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o wide
else
    log_error "Rollback failed or timed out"
    exit 1
fi

log_success "Rollback complete!"
