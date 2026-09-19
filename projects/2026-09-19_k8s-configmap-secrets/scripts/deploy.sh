#!/bin/bash
# Deployment script for Kubernetes ConfigMap and Secret management demo

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}========== Kubernetes Config Demo Deployment ==========${NC}\n"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl."
    exit 1
fi

# Check if kustomize is available
if ! command -v kustomize &> /dev/null; then
    echo "kustomize not found. Please install kustomize."
    exit 1
fi

# Function to deploy an environment
deploy_env() {
    local env=$1
    echo -e "${BLUE}Deploying environment: $env${NC}"

    kustomize build "$PROJECT_DIR/overlays/$env" | kubectl apply -f -

    echo -e "${GREEN}✓ Deployed $env environment${NC}"
    echo ""
}

# Function to delete an environment
delete_env() {
    local env=$1
    echo -e "${YELLOW}Deleting environment: $env${NC}"

    kustomize build "$PROJECT_DIR/overlays/$env" | kubectl delete -f -

    echo -e "${GREEN}✓ Deleted $env environment${NC}"
    echo ""
}

# Main menu
if [ $# -eq 0 ]; then
    echo "Usage: $0 [command] [environment]"
    echo ""
    echo "Commands:"
    echo "  deploy [env]     - Deploy specific environment (dev, staging, prod, all)"
    echo "  delete [env]     - Delete specific environment"
    echo "  all              - Deploy all environments"
    echo "  clean            - Delete all environments"
    echo "  verify           - Run verification checks"
    echo ""
    exit 0
fi

case "$1" in
    deploy)
        if [ -z "$2" ] || [ "$2" = "all" ]; then
            for env in dev staging prod; do
                deploy_env "$env"
            done
        else
            deploy_env "$2"
        fi
        ;;
    delete)
        if [ -z "$2" ]; then
            echo "Please specify environment (dev, staging, prod)"
            exit 1
        fi
        delete_env "$2"
        ;;
    all)
        for env in dev staging prod; do
            deploy_env "$env"
        done
        ;;
    clean)
        for env in dev staging prod; do
            delete_env "$env"
        done
        ;;
    verify)
        bash "$PROJECT_DIR/scripts/verify.sh"
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
        ;;
esac

echo -e "${BLUE}Done!${NC}"
