#!/bin/bash
# Verification script for Kubernetes ConfigMap and Secret deployment

set -e

ENVIRONMENTS=("dev" "staging" "prod")
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========== Kubernetes ConfigMap & Secret Verification ==========${NC}\n"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not found. Please install kubectl.${NC}"
    exit 1
fi

# Verify cluster connection
echo -e "${BLUE}Checking cluster connectivity...${NC}"
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}\n"
else
    echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

# Verify each environment
for env in "${ENVIRONMENTS[@]}"; do
    echo -e "${BLUE}=== Verifying Environment: ${env} ===${NC}"

    # Check namespace
    if kubectl get namespace "$env" &> /dev/null; then
        echo -e "${GREEN}✓ Namespace '$env' exists${NC}"
    else
        echo -e "${YELLOW}✗ Namespace '$env' not found${NC}"
        continue
    fi

    # Check ConfigMap
    if kubectl get configmap app-config -n "$env" &> /dev/null; then
        echo -e "${GREEN}✓ ConfigMap 'app-config' exists in namespace '$env'${NC}"
        echo "   Contents:"
        kubectl get configmap app-config -n "$env" -o jsonpath='{.data}' | jq '.' | sed 's/^/   /'
    else
        echo -e "${RED}✗ ConfigMap 'app-config' not found in namespace '$env'${NC}"
    fi

    echo ""

    # Check Secret
    if kubectl get secret app-secrets -n "$env" &> /dev/null; then
        echo -e "${GREEN}✓ Secret 'app-secrets' exists in namespace '$env'${NC}"
        echo "   Keys: $(kubectl get secret app-secrets -n "$env" -o jsonpath='{.data}' | jq 'keys[]' | tr '\n' ',' | sed 's/,$//')"
    else
        echo -e "${RED}✗ Secret 'app-secrets' not found in namespace '$env'${NC}"
    fi

    echo ""

    # Check Deployment
    if kubectl get deployment config-demo -n "$env" &> /dev/null; then
        echo -e "${GREEN}✓ Deployment 'config-demo' exists in namespace '$env'${NC}"
        replicas=$(kubectl get deployment config-demo -n "$env" -o jsonpath='{.spec.replicas}')
        echo "   Replicas: $replicas"
    else
        echo -e "${RED}✗ Deployment 'config-demo' not found in namespace '$env'${NC}"
    fi

    echo ""

    # Check Pods
    pod_count=$(kubectl get pods -n "$env" -l app=config-demo --no-headers 2>/dev/null | wc -l)
    if [ "$pod_count" -gt 0 ]; then
        echo -e "${GREEN}✓ Found $pod_count pod(s) in namespace '$env'${NC}"
        kubectl get pods -n "$env" -l app=config-demo --no-headers | awk '{print "   " $1 " - " $3}'
    else
        echo -e "${YELLOW}✗ No pods found in namespace '$env'${NC}"
    fi

    echo ""

    # Check Services
    if kubectl get service config-demo -n "$env" &> /dev/null; then
        echo -e "${GREEN}✓ Service 'config-demo' exists in namespace '$env'${NC}"
        port=$(kubectl get service config-demo -n "$env" -o jsonpath='{.spec.ports[0].port}')
        echo "   Port: $port"
    else
        echo -e "${RED}✗ Service 'config-demo' not found in namespace '$env'${NC}"
    fi

    echo ""
    echo "---"
    echo ""
done

echo -e "${BLUE}========== Summary Report ==========${NC}"
for env in "${ENVIRONMENTS[@]}"; do
    if kubectl get namespace "$env" &> /dev/null; then
        pod_status=$(kubectl get pods -n "$env" -l app=config-demo -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
        if [ -z "$pod_status" ]; then
            echo -e "${YELLOW}$env: No pods running${NC}"
        else
            if [[ $pod_status == *"Failed"* ]]; then
                echo -e "${RED}$env: Some pods failed${NC}"
            else
                echo -e "${GREEN}$env: OK${NC}"
            fi
        fi
    else
        echo -e "${RED}$env: Namespace not found${NC}"
    fi
done

echo -e "\n${BLUE}Verification complete!${NC}"
