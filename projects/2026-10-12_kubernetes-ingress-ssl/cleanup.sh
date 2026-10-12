#!/bin/bash
# Cleanup script for Kubernetes Ingress SSL/TLS project
# Removes all resources created by this project

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

confirm() {
    local prompt="$1"
    local response

    while true; do
        read -p "$(echo -e ${YELLOW}$prompt${NC}) (yes/no): " response
        case "$response" in
            [Yy][Ee][Ss]|[Yy])
                return 0
                ;;
            [Nn][Oo]|[Nn])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

cleanup_ingress() {
    print_header "Removing Ingress Resources"

    kubectl delete ingress --all -n default || print_warning "No ingress resources found"
    print_success "Ingress resources deleted"
}

cleanup_services() {
    print_header "Removing Backend Services and Deployments"

    # Delete deployments
    for deploy in web-app-1 web-app-2 api-backend admin-dashboard; do
        kubectl delete deployment $deploy -n default 2>/dev/null || true
    done

    # Delete services
    for svc in web-app-1 web-app-2 api-backend admin-dashboard; do
        kubectl delete service $svc -n default 2>/dev/null || true
    done

    print_success "Services and deployments deleted"
}

cleanup_certificates() {
    print_header "Removing Certificates"

    if kubectl get crd certificates.cert-manager.io &>/dev/null; then
        kubectl delete certificate --all -n default 2>/dev/null || print_warning "No certificates found"
        kubectl delete issuers --all -n default 2>/dev/null || print_warning "No issuers found"
        print_success "Certificates deleted"
    else
        print_warning "cert-manager not installed"
    fi
}

cleanup_secrets() {
    print_header "Removing Secrets"

    kubectl delete secret --all -n default 2>/dev/null || print_warning "No secrets found"
    print_success "Secrets deleted"
}

cleanup_configmaps() {
    print_header "Removing ConfigMaps"

    kubectl delete configmap --all -n default 2>/dev/null || print_warning "No configmaps found"
    print_success "ConfigMaps deleted"
}

cleanup_network_policies() {
    print_header "Removing Network Policies"

    kubectl delete networkpolicy --all -n default 2>/dev/null || print_warning "No network policies found"
    print_success "Network policies deleted"
}

cleanup_ingress_controller() {
    print_header "Removing Nginx Ingress Controller"

    # Using kubectl apply (manifests)
    kubectl delete -f 1-ingress-controller.yaml 2>/dev/null || print_warning "Could not delete ingress controller manifests"

    # Or using helm
    if helm list -n ingress-nginx | grep -q nginx-ingress; then
        helm uninstall nginx-ingress -n ingress-nginx || print_warning "Could not uninstall with helm"
    fi

    # Delete namespace if it's empty
    sleep 5
    kubectl delete namespace ingress-nginx 2>/dev/null || print_warning "Could not delete namespace"

    print_success "Ingress controller deleted"
}

cleanup_cert_manager() {
    print_header "Removing cert-manager (Optional)"

    if confirm "Do you want to remove cert-manager?"; then
        kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.crds.yaml 2>/dev/null || true
        helm uninstall cert-manager -n cert-manager 2>/dev/null || print_warning "cert-manager not installed via helm"
        kubectl delete namespace cert-manager 2>/dev/null || print_warning "Could not delete cert-manager namespace"
        print_success "cert-manager deleted"
    else
        print_warning "Skipping cert-manager removal"
    fi
}

full_cleanup() {
    print_header "Full Cleanup"

    cleanup_ingress
    echo ""
    cleanup_services
    echo ""
    cleanup_certificates
    echo ""
    cleanup_secrets
    echo ""
    cleanup_configmaps
    echo ""
    cleanup_network_policies
    echo ""
    cleanup_ingress_controller
    echo ""
    cleanup_cert_manager
}

verify_cleanup() {
    print_header "Verifying Cleanup"

    echo "Remaining resources in default namespace:"
    kubectl get all -n default || print_success "No resources in default namespace"

    echo ""
    echo "Remaining ingress namespaces:"
    kubectl get ns | grep -i ingress || print_success "No ingress namespaces found"
}

main() {
    echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Cleanup Kubernetes Ingress Project  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}\n"

    if ! confirm "This will delete all resources created by this project. Continue?"; then
        echo "Cleanup cancelled."
        exit 0
    fi

    full_cleanup

    echo ""
    verify_cleanup

    echo ""
    print_success "Cleanup completed!"
}

main "$@"
