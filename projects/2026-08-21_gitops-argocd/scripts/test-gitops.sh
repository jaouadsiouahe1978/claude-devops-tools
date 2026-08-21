#!/bin/bash

# GitOps Testing Script
# Tests ArgoCD GitOps workflow with automated validation
# Usage: bash test-gitops.sh [test-name]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="argocd"
TEST_APP="guestbook"

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

# Test 1: Verify ArgoCD Installation
test_installation() {
    print_header "Test 1: Verify ArgoCD Installation"

    # Check namespace
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_success "Namespace $NAMESPACE exists"
    else
        print_error "Namespace $NAMESPACE not found"
        return 1
    fi

    # Check deployments
    local deployments=("argocd-server" "argocd-repo-server" "argocd-application-controller")
    for deployment in "${deployments[@]}"; do
        if kubectl get deployment -n "$NAMESPACE" "$deployment" &> /dev/null; then
            print_success "Deployment $deployment exists"
        else
            print_error "Deployment $deployment not found"
            return 1
        fi
    done

    # Check pod status
    local ready_pods=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/part-of=argocd \
        -o jsonpath='{.items[?(@.status.conditions[?(@.type=="Ready")].status=="True")].metadata.name}' | wc -w)

    if [ "$ready_pods" -gt 0 ]; then
        print_success "$ready_pods ArgoCD pods are ready"
    else
        print_error "No ready ArgoCD pods found"
        return 1
    fi

    return 0
}

# Test 2: Verify Repository Connection
test_repo_connection() {
    print_header "Test 2: Verify Repository Connection"

    # Check if ArgoCD CLI is available
    if ! command -v argocd &> /dev/null; then
        print_warning "ArgoCD CLI not found, skipping CLI tests"
        return 0
    fi

    # Get server status
    if argocd app list &> /dev/null; then
        print_success "Can communicate with ArgoCD server"
    else
        print_error "Cannot communicate with ArgoCD server"
        print_warning "Make sure to run: argocd login <server> --username admin --password <password>"
        return 1
    fi

    return 0
}

# Test 3: Deploy Test Application
test_application_deployment() {
    print_header "Test 3: Deploy Test Application"

    # Check if application exists
    if kubectl get application -n "$NAMESPACE" "$TEST_APP" &> /dev/null; then
        print_success "Application $TEST_APP already exists"
    else
        print_warning "Application $TEST_APP does not exist, creating..."

        # Create test application
        cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $TEST_APP-test
  namespace: $NAMESPACE
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: $TEST_APP-test
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

        print_success "Test application created"

        # Wait for sync
        echo "Waiting for application to sync..."
        sleep 5
    fi

    return 0
}

# Test 4: Verify Application Sync
test_application_sync() {
    print_header "Test 4: Verify Application Sync"

    local app_name="$TEST_APP-test"

    # Wait for application to be created
    for i in {1..30}; do
        if kubectl get application -n "$NAMESPACE" "$app_name" &> /dev/null; then
            print_success "Application $app_name is registered"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Application $app_name did not appear"
            return 1
        fi
        sleep 1
    done

    # Check application status
    local status=$(kubectl get application -n "$NAMESPACE" "$app_name" \
        -o jsonpath='{.status.operationState.phase}' 2>/dev/null || echo "Unknown")

    if [ "$status" = "Succeeded" ]; then
        print_success "Application sync succeeded"
    elif [ "$status" = "InProgress" ]; then
        print_warning "Application sync in progress"
    else
        print_warning "Application status: $status"
    fi

    # Check destination namespace
    if kubectl get namespace "$app_name" &> /dev/null; then
        print_success "Destination namespace $app_name created"
    else
        print_warning "Destination namespace $app_name not found"
    fi

    return 0
}

# Test 5: Verify GitOps Automation
test_gitops_automation() {
    print_header "Test 5: Verify GitOps Automation"

    # Check if automated sync is enabled
    local app_name="$TEST_APP-test"
    local auto_sync=$(kubectl get application -n "$NAMESPACE" "$app_name" \
        -o jsonpath='{.spec.syncPolicy.automated.prune}' 2>/dev/null)

    if [ "$auto_sync" = "true" ]; then
        print_success "Automated sync is enabled"
    else
        print_warning "Automated sync is not enabled for this application"
    fi

    return 0
}

# Test 6: Verify Monitoring
test_monitoring() {
    print_header "Test 6: Verify Monitoring"

    # Check for metrics service
    if kubectl get service -n "$NAMESPACE" argocd-metrics &> /dev/null; then
        print_success "Metrics service found"
    else
        print_warning "Metrics service not found"
        return 1
    fi

    # Try to scrape metrics
    local metrics_pod=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=argocd-server \
        -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -n "$metrics_pod" ]; then
        if kubectl exec -n "$NAMESPACE" "$metrics_pod" -- curl -s http://localhost:8082/metrics &> /dev/null; then
            print_success "Metrics endpoint is responding"
        else
            print_warning "Could not reach metrics endpoint"
        fi
    fi

    return 0
}

# Test 7: Verify RBAC
test_rbac() {
    print_header "Test 7: Verify RBAC"

    # Check RBAC configuration
    if kubectl get configmap -n "$NAMESPACE" argocd-rbac-cm &> /dev/null; then
        print_success "RBAC ConfigMap found"
    else
        print_error "RBAC ConfigMap not found"
        return 1
    fi

    # Check service account permissions
    if kubectl auth can-i create applications --as=system:serviceaccount:$NAMESPACE:argocd-application-controller -n "$NAMESPACE" &> /dev/null; then
        print_success "Application controller has necessary permissions"
    else
        print_warning "Application controller may lack some permissions"
    fi

    return 0
}

# Test 8: Cleanup
test_cleanup() {
    print_header "Test 8: Cleanup Test Resources"

    local app_name="$TEST_APP-test"

    # Delete test application
    if kubectl get application -n "$NAMESPACE" "$app_name" &> /dev/null; then
        kubectl delete application -n "$NAMESPACE" "$app_name"
        print_success "Test application deleted"
    fi

    # Delete test namespace
    if kubectl get namespace "$app_name" &> /dev/null; then
        kubectl delete namespace "$app_name" --ignore-not-found
        print_success "Test namespace deleted"
    fi

    return 0
}

# Run all tests
run_all_tests() {
    print_header "Running All GitOps Tests"

    local total=0
    local passed=0

    tests=("installation" "repo_connection" "application_deployment" "application_sync" "gitops_automation" "monitoring" "rbac" "cleanup")

    for test in "${tests[@]}"; do
        total=$((total + 1))
        if test_$test; then
            passed=$((passed + 1))
            echo ""
        else
            print_error "Test $test failed"
            echo ""
        fi
    done

    print_header "Test Summary"
    echo "Total tests: $total"
    echo "Passed: $passed"
    echo "Failed: $((total - passed))"

    if [ $passed -eq $total ]; then
        print_success "All tests passed!"
        return 0
    else
        print_error "Some tests failed"
        return 1
    fi
}

# Run specific test
run_specific_test() {
    local test_name=$1

    if [ -z "$test_name" ]; then
        run_all_tests
        return $?
    fi

    print_header "Running Test: $test_name"

    if declare -f "test_$test_name" &> /dev/null; then
        if test_$test_name; then
            print_success "Test $test_name passed"
            return 0
        else
            print_error "Test $test_name failed"
            return 1
        fi
    else
        print_error "Test $test_name not found"
        echo "Available tests:"
        echo "  - installation"
        echo "  - repo_connection"
        echo "  - application_deployment"
        echo "  - application_sync"
        echo "  - gitops_automation"
        echo "  - monitoring"
        echo "  - rbac"
        echo "  - cleanup"
        echo "  - all (or omit test name)"
        return 1
    fi
}

# Main
echo ""
run_specific_test "$1"
echo ""
