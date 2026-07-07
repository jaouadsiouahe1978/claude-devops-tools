#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
ENVIRONMENT="dev"
ACTION="install"
RELEASE_NAME="myapp"
CHART_PATH="."

# Help function
print_help() {
    cat <<EOF
${BLUE}Helm Chart Deployment Script${NC}

Usage: ./deploy.sh [OPTIONS]

Options:
  -e, --environment ENV    Environment to deploy (dev, test, prod) - default: dev
  -a, --action ACTION      Action to perform (install, upgrade, uninstall, status) - default: install
  -r, --release NAME       Release name - default: myapp
  -c, --chart PATH         Chart path - default: .
  -h, --help               Show this help message

Examples:
  ./deploy.sh -e dev
  ./deploy.sh -e prod -a upgrade
  ./deploy.sh -e test -a uninstall
  ./deploy.sh -a status -e dev

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -c|--chart)
            CHART_PATH="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
    echo "Valid environments: dev, test, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(install|upgrade|uninstall|status)$ ]]; then
    echo -e "${RED}Invalid action: $ACTION${NC}"
    echo "Valid actions: install, upgrade, uninstall, status"
    exit 1
fi

# Get namespace from values file
NAMESPACE_FILE="environments/${ENVIRONMENT}-values.yaml"
if [[ ! -f "$NAMESPACE_FILE" ]]; then
    echo -e "${RED}Values file not found: $NAMESPACE_FILE${NC}"
    exit 1
fi

NAMESPACE=$(grep 'namespace:' "$NAMESPACE_FILE" | head -1 | sed 's/.*namespace: //' | tr -d ' ')

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Helm Chart Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Namespace:   ${YELLOW}$NAMESPACE${NC}"
echo -e "Release:     ${YELLOW}$RELEASE_NAME${NC}"
echo -e "Action:      ${YELLOW}$ACTION${NC}"
echo -e "Chart Path:  ${YELLOW}$CHART_PATH${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Helm is not installed. Please install Helm first.${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check Kubernetes connectivity
echo -e "${BLUE}Checking Kubernetes connectivity...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}"
echo

# Create namespace if it doesn't exist
echo -e "${BLUE}Ensuring namespace exists...${NC}"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace ready: $NAMESPACE${NC}"
echo

# Perform action
case $ACTION in
    install)
        echo -e "${BLUE}Installing Helm release...${NC}"
        helm install "$RELEASE_NAME" "$CHART_PATH" \
            -f "environments/${ENVIRONMENT}-values.yaml" \
            -n "$NAMESPACE" \
            --create-namespace
        echo -e "${GREEN}✓ Installation complete${NC}"
        ;;
    upgrade)
        echo -e "${BLUE}Upgrading Helm release...${NC}"
        helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
            -f "environments/${ENVIRONMENT}-values.yaml" \
            -n "$NAMESPACE"
        echo -e "${GREEN}✓ Upgrade complete${NC}"
        ;;
    uninstall)
        echo -e "${YELLOW}Uninstalling Helm release...${NC}"
        read -p "Are you sure you want to uninstall $RELEASE_NAME from $NAMESPACE? (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
            echo -e "${GREEN}✓ Uninstall complete${NC}"
        else
            echo -e "${YELLOW}Uninstall cancelled${NC}"
        fi
        ;;
    status)
        echo -e "${BLUE}Checking Helm release status...${NC}"
        helm status "$RELEASE_NAME" -n "$NAMESPACE"
        echo
        echo -e "${BLUE}Checking pod status...${NC}"
        kubectl get pods -n "$NAMESPACE"
        echo
        echo -e "${BLUE}Checking services...${NC}"
        kubectl get svc -n "$NAMESPACE"
        ;;
esac

echo
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Done!${NC}"
echo -e "${BLUE}========================================${NC}"
