#!/bin/bash

# Kubernetes Network Policies Testing & Debugging Helper Script
# Usage: ./helpers.sh <command> [options]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
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

# Setup cluster with Calico
setup_cluster() {
    print_header "Setting up Kubernetes cluster with Calico CNI"

    if command -v kind &> /dev/null; then
        print_success "Using Kind"
        kind create cluster --config kind-config.yaml --name netpolicy-lab
        kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
        kubectl wait --for=condition=Ready pod -l k8s-app=calico-kube-controllers -n calico-system --timeout=300s 2>/dev/null || true
    elif command -v minikube &> /dev/null; then
        print_success "Using Minikube"
        minikube start --cni=calico
    else
        print_error "Please install Kind or Minikube"
        exit 1
    fi
}

# Deploy all components
deploy_all() {
    print_header "Deploying namespaces and applications"

    kubectl apply -f 01-namespaces.yaml
    kubectl apply -f 02-applications.yaml

    print_warning "Waiting for pods to be ready..."
    kubectl wait --for=condition=Ready pod -l app=frontend -n frontend --timeout=300s || true
    kubectl wait --for=condition=Ready pod -l app=api -n api --timeout=300s || true
    kubectl wait --for=condition=Ready pod -l app=database -n database --timeout=300s || true

    print_success "All applications deployed"
}

# Test connectivity before policies
test_before_policies() {
    print_header "Testing connectivity BEFORE network policies (should all work)"

    FE_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    if [ -z "$FE_POD" ]; then
        print_error "Frontend pod not found. Deploy applications first."
        return 1
    fi

    print_warning "Frontend → API (port 5000)"
    if kubectl exec -it -n frontend $FE_POD -- timeout 3 curl -s http://api-service.api:5000/status > /dev/null 2>&1; then
        print_success "✓ Connection succeeded (expected)"
    else
        print_error "✗ Connection failed (unexpected)"
    fi

    print_warning "Frontend → Database (port 3306)"
    if kubectl exec -it -n frontend $FE_POD -- timeout 3 nc -zv db-service.database 3306 > /dev/null 2>&1; then
        print_success "✓ Connection succeeded (expected - no policies yet)"
    else
        print_warning "⚠ Connection failed (might fail if MySQL not ready)"
    fi
}

# Apply network policies
apply_policies() {
    print_header "Applying network policies (zero-trust networking)"

    kubectl apply -f 03-default-deny-all.yaml
    kubectl apply -f 04-allow-frontend-to-api.yaml
    kubectl apply -f 05-allow-api-to-database.yaml
    kubectl apply -f 06-allow-dns.yaml

    print_warning "Waiting for policies to take effect..."
    sleep 5

    print_success "All network policies applied"
}

# Test connectivity after policies
test_after_policies() {
    print_header "Testing connectivity AFTER network policies"

    FE_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    if [ -z "$FE_POD" ]; then
        print_error "Frontend pod not found."
        return 1
    fi

    print_warning "Frontend → API (port 5000) - should WORK (allowed)"
    if kubectl exec -it -n frontend $FE_POD -- timeout 3 curl -s http://api-service.api:5000/status > /dev/null 2>&1; then
        print_success "✓ Connection succeeded (expected - allowed by policy)"
    else
        print_error "✗ Connection failed (unexpected - should be allowed)"
    fi

    print_warning "Frontend → Database (port 3306) - should FAIL (blocked)"
    if kubectl exec -it -n frontend $FE_POD -- timeout 3 nc -zv db-service.database 3306 > /dev/null 2>&1; then
        print_error "✗ Connection succeeded (unexpected - should be blocked)"
    else
        print_success "✓ Connection failed (expected - blocked by policy)"
    fi
}

# View network policies
view_policies() {
    print_header "Current Network Policies"
    kubectl get networkpolicies -A
}

# Describe specific policy
describe_policy() {
    local namespace=$1
    local policy=$2

    if [ -z "$namespace" ] || [ -z "$policy" ]; then
        print_error "Usage: ./helpers.sh describe-policy <namespace> <policy-name>"
        return 1
    fi

    print_header "Network Policy Details: $namespace/$policy"
    kubectl describe networkpolicy $policy -n $namespace
}

# Interactive debug pod
debug_pod() {
    local namespace=${1:-frontend}

    print_header "Launching debug pod in namespace: $namespace"
    print_warning "You can run commands like:"
    print_warning "  - nslookup api-service.api"
    print_warning "  - curl http://api-service.api:5000/status"
    print_warning "  - nc -zv db-service.database 3306"
    print_warning "Type 'exit' to quit"
    echo ""

    kubectl run -it --rm debug --image=nicolaka/netshoot -n $namespace --restart=Never -- bash
}

# View pod labels
show_pod_labels() {
    print_header "Pod Labels (used for network policy selection)"

    echo -e "${BLUE}Frontend Pods:${NC}"
    kubectl get pods -n frontend --show-labels

    echo -e "\n${BLUE}API Pods:${NC}"
    kubectl get pods -n api --show-labels

    echo -e "\n${BLUE}Database Pods:${NC}"
    kubectl get pods -n database --show-labels
}

# Check CNI status
check_cni() {
    print_header "CNI Plugin Status"
    kubectl get pods -n kube-system | grep -E "calico|flannel|weave" || print_warning "No CNI pods found. Install Calico/Flannel/Weave"
}

# Clean up everything
cleanup() {
    print_header "Cleaning up resources"

    kubectl delete namespace frontend api database --ignore-not-found=true

    print_success "Resources cleaned up"
}

# Display help
show_help() {
    cat << EOF
${BLUE}Kubernetes Network Policies Lab - Helper Script${NC}

Usage: ./helpers.sh <command> [options]

Commands:
    setup-cluster           - Create Kind cluster with Calico
    deploy-all              - Deploy namespaces and applications
    test-before             - Test connectivity before policies
    apply-policies          - Apply network policies (zero-trust)
    test-after              - Test connectivity after policies
    view-policies           - Show all network policies
    describe-policy NS POL  - Show policy details (e.g., api allow-from-frontend)
    debug-pod [NAMESPACE]   - Launch interactive debug pod
    show-labels             - Display pod labels used by policies
    check-cni               - Check CNI plugin status
    cleanup                 - Delete all resources
    help                    - Show this help message

${YELLOW}Quick Start:${NC}
    1. ./helpers.sh setup-cluster
    2. ./helpers.sh deploy-all
    3. ./helpers.sh test-before
    4. ./helpers.sh apply-policies
    5. ./helpers.sh test-after
    6. ./helpers.sh debug-pod frontend

${YELLOW}Learning Path:${NC}
    - Run 'test-before' to see unrestricted connectivity
    - Run 'apply-policies' to enforce zero-trust
    - Run 'test-after' to verify only allowed traffic works
    - Use 'debug-pod' to manually test specific connectivity
    - Use 'describe-policy' to understand policy rules
EOF
}

# Main
case "${1:-help}" in
    setup-cluster)
        setup_cluster
        ;;
    deploy-all)
        deploy_all
        ;;
    test-before)
        test_before_policies
        ;;
    apply-policies)
        apply_policies
        ;;
    test-after)
        test_after_policies
        ;;
    view-policies)
        view_policies
        ;;
    describe-policy)
        describe_policy "$2" "$3"
        ;;
    debug-pod)
        debug_pod "$2"
        ;;
    show-labels)
        show_pod_labels
        ;;
    check-cni)
        check_cni
        ;;
    cleanup)
        cleanup
        ;;
    help)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
