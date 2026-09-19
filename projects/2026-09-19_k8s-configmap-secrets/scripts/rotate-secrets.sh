#!/bin/bash
# Secret rotation script - demonstrates safe secret update pattern

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -lt 2 ]; then
    echo "Usage: $0 <environment> <secret-name>"
    echo "Example: $0 prod db-password"
    exit 1
fi

ENV=$1
SECRET_NAME=$2
NAMESPACE=$ENV

echo -e "${BLUE}========== Secret Rotation Tool ==========${NC}\n"

# Validate environment
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Invalid environment. Must be dev, staging, or prod${NC}"
    exit 1
fi

# Check if secret exists
if ! kubectl get secret app-secrets -n "$NAMESPACE" &> /dev/null; then
    echo -e "${RED}Secret app-secrets not found in namespace $NAMESPACE${NC}"
    exit 1
fi

# Get current secret value
echo -e "${YELLOW}Current secret keys in namespace $NAMESPACE:${NC}"
kubectl get secret app-secrets -n "$NAMESPACE" -o jsonpath='{.data}' | jq 'keys[]'
echo ""

# Check which secret to rotate
case "$SECRET_NAME" in
    db-password)
        echo -e "${BLUE}Rotating database password in $ENV environment...${NC}"
        NEW_VALUE=$(openssl rand -base64 32)
        echo -e "${YELLOW}New password (save this): ${NC}$NEW_VALUE"
        ;;
    api-key)
        echo -e "${BLUE}Rotating API key in $ENV environment...${NC}"
        NEW_VALUE=$(openssl rand -hex 32)
        echo -e "${YELLOW}New API key (save this): ${NC}$NEW_VALUE"
        ;;
    jwt-secret)
        echo -e "${BLUE}Rotating JWT secret in $ENV environment...${NC}"
        NEW_VALUE=$(openssl rand -base64 48)
        echo -e "${YELLOW}New JWT secret (save this): ${NC}$NEW_VALUE"
        ;;
    *)
        echo -e "${RED}Unknown secret: $SECRET_NAME${NC}"
        echo -e "${YELLOW}Available secrets: db-password, api-key, jwt-secret${NC}"
        exit 1
        ;;
esac

echo ""
read -p "Continue with rotation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Rotation cancelled${NC}"
    exit 0
fi

# Backup current secret
echo -e "${BLUE}Creating backup of current secret...${NC}"
kubectl get secret app-secrets -n "$NAMESPACE" -o yaml > "/tmp/app-secrets-backup-${NAMESPACE}-$(date +%s).yaml"
echo -e "${GREEN}✓ Backup created${NC}"
echo ""

# Update secret
echo -e "${BLUE}Updating secret in Kubernetes...${NC}"
kubectl patch secret app-secrets -n "$NAMESPACE" -p "{\"data\":{\"$SECRET_NAME\":\"$(echo -n "$NEW_VALUE" | base64 -w 0)\"}}"
echo -e "${GREEN}✓ Secret updated${NC}"
echo ""

# Get rolling deployment update info
echo -e "${BLUE}Triggering pod restart to pick up new secret...${NC}"
kubectl rollout restart deployment/config-demo -n "$NAMESPACE"
kubectl rollout status deployment/config-demo -n "$NAMESPACE" --timeout=5m
echo -e "${GREEN}✓ Pods restarted with new secret${NC}"
echo ""

echo -e "${GREEN}========== Secret Rotation Complete ==========${NC}"
echo -e "${YELLOW}Important: Update your secret management system with:${NC}"
echo -e "  Secret: $SECRET_NAME"
echo -e "  New Value: $NEW_VALUE"
echo -e "  Rotated At: $(date)"
echo -e "  Environment: $ENV"
