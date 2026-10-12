#!/bin/bash
# Test script for Kubernetes Ingress with SSL/TLS
# Tests various endpoints and configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INGRESS_IP=""
INGRESS_PORT_HTTP=80
INGRESS_PORT_HTTPS=443
TIMEOUT=5

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

# Get Ingress IP
get_ingress_ip() {
    print_header "Getting Ingress IP"

    # Try LoadBalancer IP first
    INGRESS_IP=$(kubectl get svc -n ingress-nginx nginx-ingress \
        -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

    if [ -z "$INGRESS_IP" ]; then
        # Fallback to hostname
        INGRESS_IP=$(kubectl get svc -n ingress-nginx nginx-ingress \
            -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    fi

    if [ -z "$INGRESS_IP" ]; then
        # Fallback to ClusterIP for minikube
        INGRESS_IP=$(kubectl get svc -n ingress-nginx nginx-ingress \
            -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    fi

    # Minikube specific
    if [ -z "$INGRESS_IP" ] && command -v minikube &> /dev/null; then
        INGRESS_IP=$(minikube service nginx-ingress -n ingress-nginx --url | head -1 | sed 's|http://||' | cut -d: -f1)
    fi

    if [ -z "$INGRESS_IP" ]; then
        print_error "Could not determine Ingress IP"
        return 1
    fi

    print_success "Ingress IP: $INGRESS_IP"
}

# Check if Ingress controller is ready
check_ingress_controller() {
    print_header "Checking Ingress Controller Status"

    # Check pods
    kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

    # Check if ready
    READY=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx \
        -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')

    if [ "$READY" = "True" ]; then
        print_success "Ingress controller is ready"
    else
        print_warning "Ingress controller may not be ready yet"
    fi
}

# Check services
check_services() {
    print_header "Checking Backend Services"

    kubectl get svc -n default

    # Check endpoints
    for svc in web-app-1 web-app-2 api-backend admin-dashboard; do
        ENDPOINTS=$(kubectl get endpoints $svc -n default -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w)
        if [ "$ENDPOINTS" -gt 0 ]; then
            print_success "Service $svc has $ENDPOINTS endpoints"
        else
            print_warning "Service $svc has no endpoints"
        fi
    done
}

# Check Ingress
check_ingress() {
    print_header "Checking Ingress Resources"

    kubectl get ingress -n default
}

# Check certificates
check_certificates() {
    print_header "Checking Certificates"

    if kubectl get crd certificates.cert-manager.io &>/dev/null; then
        kubectl get certificate -n default
    else
        print_warning "cert-manager CRD not found"
    fi
}

# Test HTTP connectivity
test_http() {
    print_header "Testing HTTP Connectivity"

    # Test with curl
    print_warning "Testing basic HTTP (may fail if only HTTPS configured)"
    curl -I --max-time $TIMEOUT http://$INGRESS_IP/ 2>/dev/null || print_warning "HTTP request failed or timed out"
}

# Test HTTPS connectivity
test_https() {
    print_header "Testing HTTPS Connectivity"

    print_warning "Testing HTTPS (may show certificate warning)"
    curl -I -k --max-time $TIMEOUT https://$INGRESS_IP/ 2>/dev/null || print_warning "HTTPS request failed or timed out"
}

# Test with hostname header
test_hostname() {
    print_header "Testing with Hostname Headers"

    HOSTS=(
        "example.local"
        "www.example.local"
        "api.example.local"
        "admin.example.local"
    )

    for host in "${HOSTS[@]}"; do
        echo -n "Testing $host ... "
        if curl -I -H "Host: $host" --max-time $TIMEOUT http://$INGRESS_IP/ 2>/dev/null | grep -q "200\|301\|302\|404"; then
            print_success "$host responded"
        else
            print_warning "$host did not respond or timed out"
        fi
    done
}

# Test paths
test_paths() {
    print_header "Testing Path-based Routing"

    PATHS=(
        "/"
        "/app2"
        "/api"
        "/health"
    )

    for path in "${PATHS[@]}"; do
        echo -n "Testing path $path ... "
        if curl -I --max-time $TIMEOUT http://$INGRESS_IP$path 2>/dev/null | grep -q "200\|301\|302\|404"; then
            print_success "$path responded"
        else
            print_warning "$path did not respond or timed out"
        fi
    done
}

# Test SSL certificate
test_ssl_cert() {
    print_header "Checking SSL Certificate"

    echo "Certificate info:"
    openssl s_client -connect $INGRESS_IP:443 -servername example.local \
        < /dev/null 2>&1 | openssl x509 -noout -text 2>/dev/null | head -20 || print_warning "Could not retrieve certificate"
}

# Test rate limiting
test_rate_limiting() {
    print_header "Testing Rate Limiting"

    echo "Sending multiple rapid requests to test rate limiting..."

    for i in {1..20}; do
        curl -s -o /dev/null -w "%{http_code}\n" -H "Host: api.example.local" http://$INGRESS_IP/ &
    done
    wait

    print_success "Rate limiting test completed"
}

# Show logs
show_logs() {
    print_header "Nginx Ingress Controller Logs (last 20 lines)"

    kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=20 || print_warning "Could not retrieve logs"
}

# Main execution
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Kubernetes Ingress SSL/TLS Test     ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}\n"

    get_ingress_ip || exit 1

    echo ""
    check_ingress_controller
    echo ""
    check_services
    echo ""
    check_ingress
    echo ""
    check_certificates
    echo ""
    test_http
    echo ""
    test_https
    echo ""
    test_hostname
    echo ""
    test_paths
    echo ""
    test_ssl_cert
    echo ""
    show_logs

    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    print_success "Test suite completed"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

# Run main
main "$@"
