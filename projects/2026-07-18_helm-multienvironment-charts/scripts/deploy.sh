#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
RELEASE_NAME="myapp"
NAMESPACE="default"
ENVIRONMENT="dev"
CHART_PATH="."
DRY_RUN=false
VERBOSE=false

# Function to print colored output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy a Helm chart to Kubernetes

OPTIONS:
    -r, --release       Release name (default: myapp)
    -n, --namespace     Kubernetes namespace (default: default)
    -e, --environment   Environment (dev/staging/production, default: dev)
    -c, --chart         Path to chart (default: .)
    --dry-run          Perform a dry-run (default: false)
    -v, --verbose      Enable verbose output
    -h, --help         Show this help message

EXAMPLES:
    ./deploy.sh -e dev -n dev
    ./deploy.sh -e production -n production --dry-run
    ./deploy.sh -r myapp-v2 -e staging -n staging

EOF
    exit 0
}

# Parse command line arguments
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
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -c|--chart)
            CHART_PATH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
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

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT"
    exit 1
fi

# Validate chart path
if [[ ! -f "$CHART_PATH/Chart.yaml" ]]; then
    log_error "Chart not found at $CHART_PATH/Chart.yaml"
    exit 1
fi

VALUES_FILE="$CHART_PATH/values-${ENVIRONMENT}.yaml"
if [[ ! -f "$VALUES_FILE" ]]; then
    log_error "Values file not found: $VALUES_FILE"
    exit 1
fi

log_info "Deploying chart: $CHART_PATH"
log_info "Release: $RELEASE_NAME"
log_info "Namespace: $NAMESPACE"
log_info "Environment: $ENVIRONMENT"

# Check if namespace exists, create if not
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    log_info "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
    log_success "Namespace created"
fi

# Lint chart
log_info "Linting chart..."
if helm lint "$CHART_PATH" --values "$VALUES_FILE"; then
    log_success "Chart lint passed"
else
    log_error "Chart lint failed"
    exit 1
fi

# Prepare Helm command
HELM_CMD="helm upgrade --install $RELEASE_NAME $CHART_PATH"
HELM_CMD="$HELM_CMD --namespace $NAMESPACE"
HELM_CMD="$HELM_CMD --values $VALUES_FILE"

if [[ "$DRY_RUN" == true ]]; then
    HELM_CMD="$HELM_CMD --dry-run --debug"
    log_warn "Running in DRY-RUN mode"
fi

if [[ "$VERBOSE" == true ]]; then
    HELM_CMD="$HELM_CMD --debug"
fi

# Execute Helm command
log_info "Executing: $HELM_CMD"
eval "$HELM_CMD"

if [[ "$DRY_RUN" == false ]]; then
    log_success "Release deployed successfully"

    # Wait for deployment rollout
    log_info "Waiting for deployment to be ready..."
    if kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m; then
        log_success "Deployment is ready"

        # Display deployment status
        log_info "Deployment status:"
        kubectl get deployment "$RELEASE_NAME" -n "$NAMESPACE" -o wide

        log_info "Pods:"
        kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o wide
    else
        log_warn "Deployment rollout timeout or failed"
        exit 1
    fi
else
    log_success "Dry-run completed successfully"
fi

log_success "Deployment complete!"
