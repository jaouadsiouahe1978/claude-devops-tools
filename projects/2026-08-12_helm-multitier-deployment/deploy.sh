#!/bin/bash

# Helm Multi-Tier Deployment Script
# Usage: ./deploy.sh [dev|test|prod]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHART_DIR="./helm-chart"
EXAMPLES_DIR="./examples"
RELEASE_NAME="multitier-app"
DEFAULT_ENV="dev"

# Functions
print_header() {
    echo -e "${BLUE}▶ $1${NC}"
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

check_prerequisites() {
    print_header "Checking prerequisites..."

    # Check helm
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed"
        exit 1
    fi
    print_success "Helm is installed: $(helm version --short)"

    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    print_success "kubectl is installed"

    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

validate_chart() {
    print_header "Validating Helm chart..."

    # Lint the chart
    if helm lint "$CHART_DIR"; then
        print_success "Chart validation passed"
    else
        print_error "Chart validation failed"
        exit 1
    fi
}

create_namespace() {
    local env=$1
    local namespace=$env

    print_header "Creating namespace: $namespace"

    if kubectl get namespace "$namespace" &> /dev/null; then
        print_warning "Namespace $namespace already exists"
    else
        kubectl create namespace "$namespace"
        print_success "Namespace $namespace created"
    fi

    # Label namespace
    kubectl label namespace "$namespace" env="$env" --overwrite
}

deploy_release() {
    local env=$1
    local namespace=$env
    local values_file="$EXAMPLES_DIR/values-$env.yaml"
    local release_name="${RELEASE_NAME}-${env}"

    print_header "Deploying to $env environment"

    # Check if values file exists
    if [ ! -f "$values_file" ]; then
        print_error "Values file not found: $values_file"
        exit 1
    fi

    # Check if release exists
    if helm list -n "$namespace" | grep -q "^$release_name"; then
        print_header "Upgrading existing release: $release_name"
        helm upgrade "$release_name" "$CHART_DIR" \
            -f "$values_file" \
            -n "$namespace" \
            --wait \
            --timeout 5m
    else
        print_header "Installing new release: $release_name"
        helm install "$release_name" "$CHART_DIR" \
            -f "$values_file" \
            -n "$namespace" \
            --wait \
            --timeout 5m
    fi

    print_success "Release deployed successfully"
}

verify_deployment() {
    local env=$1
    local namespace=$env

    print_header "Verifying deployment in namespace: $namespace"

    # Wait for deployments
    echo "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s \
        deployment -n "$namespace" -l app.kubernetes.io/instance=multitier-app-$env

    # Show deployment status
    print_header "Deployment Status:"
    kubectl get all -n "$namespace"

    # Show pod logs
    print_header "Checking pod logs..."
    kubectl get pods -n "$namespace" -o name | head -1 | xargs -I {} kubectl logs {} -n "$namespace" --tail=10 || true
}

get_access_info() {
    local env=$1
    local namespace=$env

    print_header "Access Information for $env environment:"

    # Get frontend service
    local frontend_svc="multitier-app-${env}-frontend"
    echo ""
    echo -e "${YELLOW}Frontend Service:${NC}"
    kubectl get svc "$frontend_svc" -n "$namespace" 2>/dev/null || echo "Service not found"

    # Get port forward commands
    echo ""
    echo -e "${YELLOW}Quick Access (Port Forward):${NC}"
    echo "  Frontend: kubectl port-forward -n $namespace svc/$frontend_svc 3000:80"
    echo "  Backend:  kubectl port-forward -n $namespace svc/multitier-app-${env}-backend 5000:5000"
    echo "  Database: kubectl port-forward -n $namespace svc/multitier-app-${env}-postgresql 5432:5432"

    # If ingress is enabled, show ingress info
    if kubectl get ingress -n "$namespace" 2>/dev/null | grep -q multitier; then
        echo ""
        echo -e "${YELLOW}Ingress:${NC}"
        kubectl get ingress -n "$namespace"
    fi
}

show_usage() {
    cat << EOF
${BLUE}Helm Multi-Tier Deployment Script${NC}

Usage: ./deploy.sh [COMMAND] [ENVIRONMENT]

Commands:
  install    Install a new release (default)
  upgrade    Upgrade existing release
  validate   Validate chart only
  verify     Verify existing deployment
  uninstall  Uninstall a release
  status     Show deployment status
  logs       Show pod logs

Environments:
  dev        Development (default)
  test       Testing/Staging
  prod       Production

Examples:
  ./deploy.sh dev                    # Install to dev
  ./deploy.sh upgrade prod           # Upgrade prod
  ./deploy.sh validate               # Validate chart
  ./deploy.sh status test            # Show test status
  ./deploy.sh logs prod              # Show prod logs

EOF
}

main() {
    local command="${1:-install}"
    local env="${2:-$DEFAULT_ENV}"

    case "$command" in
        install)
            check_prerequisites
            validate_chart
            create_namespace "$env"
            deploy_release "$env"
            verify_deployment "$env"
            get_access_info "$env"
            print_success "Deployment completed!"
            ;;
        upgrade)
            check_prerequisites
            validate_chart
            deploy_release "$env"
            verify_deployment "$env"
            print_success "Upgrade completed!"
            ;;
        validate)
            check_prerequisites
            validate_chart
            print_success "Chart is valid"
            ;;
        verify)
            check_prerequisites
            verify_deployment "$env"
            get_access_info "$env"
            ;;
        uninstall)
            print_header "Uninstalling release from $env environment"
            helm uninstall "multitier-app-$env" -n "$env" || print_warning "Release not found"
            print_success "Release uninstalled"
            ;;
        status)
            check_prerequisites
            kubectl get all -n "$env"
            ;;
        logs)
            check_prerequisites
            print_header "Showing logs from $env environment"
            kubectl get pods -n "$env" -o name | head -1 | xargs -I {} kubectl logs {} -n "$env" -f || true
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
