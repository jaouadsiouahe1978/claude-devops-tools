#!/bin/bash

# Common Helm and Kubernetes commands for managing the myapp deployment

RELEASE_NAME="myapp"
NAMESPACE="default"
CHART_DIR="./charts/myapp-chart"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Usage: $0 <command> [options]

Available commands:

  install [dev|prod]          Install/create the Helm release
  upgrade [dev|prod]          Upgrade an existing release
  rollback [version]          Rollback to previous release version
  status                      Show release status
  values                      Show current values
  history                     Show release history
  uninstall                   Delete the release
  list                        List all resources
  logs [component]            View logs (frontend/backend/db)
  port-forward [component]    Port forward to a service
  scale [component] [replicas]  Scale a deployment
  restart [component]         Restart a deployment
  describe [component]        Describe a resource
  events                      Show recent events
  resources                   Show resource usage
  verify                      Verify chart syntax
  diff                        Show differences (requires helm-diff plugin)
  test                        Run helm tests
  help                        Show this help message

Examples:
  $0 install dev              # Install with dev values
  $0 upgrade prod             # Upgrade with prod values
  $0 logs backend             # View backend logs
  $0 port-forward frontend    # Port forward to frontend service

EOF
}

# Verify environment
verify_env() {
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed"
        exit 1
    fi
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
}

# Install release
cmd_install() {
    local env=${1:-dev}
    local values_file="$CHART_DIR/values-${env}.yaml"

    if [ ! -f "$values_file" ]; then
        print_error "Values file not found: $values_file"
        exit 1
    fi

    print_info "Installing $RELEASE_NAME with $env configuration..."
    helm install $RELEASE_NAME "$CHART_DIR" \
        -n $NAMESPACE \
        -f "$values_file" \
        --create-namespace

    print_success "Release installed successfully"
    helm status $RELEASE_NAME -n $NAMESPACE
}

# Upgrade release
cmd_upgrade() {
    local env=${1:-dev}
    local values_file="$CHART_DIR/values-${env}.yaml"

    if [ ! -f "$values_file" ]; then
        print_error "Values file not found: $values_file"
        exit 1
    fi

    print_info "Upgrading $RELEASE_NAME with $env configuration..."
    helm upgrade $RELEASE_NAME "$CHART_DIR" \
        -n $NAMESPACE \
        -f "$values_file"

    print_success "Release upgraded successfully"
}

# Rollback release
cmd_rollback() {
    local version=${1:-1}
    print_info "Rolling back to version $version..."
    helm rollback $RELEASE_NAME $version -n $NAMESPACE
    print_success "Rollback complete"
}

# Show release status
cmd_status() {
    helm status $RELEASE_NAME -n $NAMESPACE
}

# Show values
cmd_values() {
    helm get values $RELEASE_NAME -n $NAMESPACE
}

# Show history
cmd_history() {
    helm history $RELEASE_NAME -n $NAMESPACE
}

# Uninstall release
cmd_uninstall() {
    read -p "Are you sure you want to uninstall $RELEASE_NAME? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstalling $RELEASE_NAME..."
        helm uninstall $RELEASE_NAME -n $NAMESPACE
        print_success "Release uninstalled"
    else
        print_info "Uninstall cancelled"
    fi
}

# List resources
cmd_list() {
    print_info "Deployments:"
    kubectl get deployments -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"
    echo ""
    print_info "Services:"
    kubectl get services -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"
    echo ""
    print_info "Pods:"
    kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"
    echo ""
    print_info "ConfigMaps:"
    kubectl get configmaps -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"
}

# View logs
cmd_logs() {
    local component=${1:-frontend}
    print_info "Logs for $component:"
    kubectl logs -n $NAMESPACE \
        -l "app.kubernetes.io/instance=$RELEASE_NAME,component=$component" \
        --tail=100 \
        -f
}

# Port forward
cmd_port_forward() {
    local component=${1:-frontend}
    local port=${2:-8080}

    local service_name="$RELEASE_NAME-$component"
    print_info "Port forwarding $service_name to localhost:$port..."
    kubectl port-forward -n $NAMESPACE "svc/$service_name" "$port:80"
}

# Scale deployment
cmd_scale() {
    local component=${1:-backend}
    local replicas=${2:-3}

    print_info "Scaling $component to $replicas replicas..."
    kubectl scale deployment -n $NAMESPACE \
        "$RELEASE_NAME-$component" \
        --replicas=$replicas

    print_success "Scaled successfully"
}

# Restart deployment
cmd_restart() {
    local component=${1:-backend}
    print_info "Restarting $component..."
    kubectl rollout restart deployment -n $NAMESPACE "$RELEASE_NAME-$component"
    print_success "Rollout restart triggered"
}

# Describe resource
cmd_describe() {
    local component=${1:-frontend}
    kubectl describe deployment -n $NAMESPACE "$RELEASE_NAME-$component"
}

# Show events
cmd_events() {
    kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -20
}

# Show resources usage
cmd_resources() {
    print_info "Node resources:"
    kubectl top nodes 2>/dev/null || echo "Metrics not available (metrics-server might not be installed)"
    echo ""
    print_info "Pod resources:"
    kubectl top pods -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME" 2>/dev/null || echo "Metrics not available"
}

# Verify chart
cmd_verify() {
    print_info "Verifying chart..."
    helm lint "$CHART_DIR"
    echo ""
    helm template $RELEASE_NAME "$CHART_DIR" > /dev/null
    print_success "Chart verification passed"
}

# Test chart
cmd_test() {
    print_info "Running Helm tests..."
    helm test $RELEASE_NAME -n $NAMESPACE
}

# Main
verify_env

case "${1:-help}" in
    install)    cmd_install "${2:-dev}" ;;
    upgrade)    cmd_upgrade "${2:-dev}" ;;
    rollback)   cmd_rollback "$2" ;;
    status)     cmd_status ;;
    values)     cmd_values ;;
    history)    cmd_history ;;
    uninstall)  cmd_uninstall ;;
    list)       cmd_list ;;
    logs)       cmd_logs "$2" ;;
    port-forward) cmd_port_forward "$2" "$3" ;;
    scale)      cmd_scale "$2" "$3" ;;
    restart)    cmd_restart "$2" ;;
    describe)   cmd_describe "$2" ;;
    events)     cmd_events ;;
    resources)  cmd_resources ;;
    verify)     cmd_verify ;;
    test)       cmd_test ;;
    *)          show_help ;;
esac
