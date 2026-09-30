#!/bin/bash

set -e

# Script de déploiement pour l'application

ENVIRONMENT=${1:-staging}
REGISTRY=${2:-ghcr.io}
IMAGE_NAME="github-actions-cicd"
VERSION=${VERSION:-latest}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Deployment Script ===${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Registry: ${REGISTRY}${NC}"
echo -e "${BLUE}Image: ${IMAGE_NAME}:${VERSION}${NC}"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"

    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Docker is installed${NC}"
}

# Function to build Docker image
build_image() {
    echo -e "${YELLOW}Building Docker image...${NC}"
    docker build -t ${REGISTRY}/${IMAGE_NAME}:${VERSION} .
    docker tag ${REGISTRY}/${IMAGE_NAME}:${VERSION} ${REGISTRY}/${IMAGE_NAME}:latest
    echo -e "${GREEN}✓ Image built successfully${NC}"
}

# Function to scan image for vulnerabilities
scan_image() {
    echo -e "${YELLOW}Scanning image for vulnerabilities...${NC}"

    if command -v trivy &> /dev/null; then
        trivy image ${REGISTRY}/${IMAGE_NAME}:${VERSION} --severity HIGH,CRITICAL || true
        echo -e "${GREEN}✓ Image scan completed${NC}"
    else
        echo -e "${YELLOW}Trivy not found, skipping vulnerability scan${NC}"
    fi
}

# Function to deploy to staging
deploy_staging() {
    echo -e "${YELLOW}Deploying to staging...${NC}"

    # Simulate deployment
    echo -e "${BLUE}Mock Deployment Steps:${NC}"
    echo "1. Pull latest image from registry"
    echo "2. Stop current container"
    echo "3. Start new container with image ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
    echo "4. Wait for health checks"
    echo "5. Verify deployment"

    sleep 2
    echo -e "${GREEN}✓ Staging deployment completed${NC}"
}

# Function to deploy to production
deploy_production() {
    echo -e "${YELLOW}Deploying to production...${NC}"

    read -p "⚠️  This will deploy to PRODUCTION. Continue? (yes/no) " -n 3 -r
    echo
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${BLUE}Mock Production Deployment:${NC}"
        echo "1. Backup current production state"
        echo "2. Pull image from registry"
        echo "3. Perform blue-green deployment"
        echo "4. Run health checks"
        echo "5. Update load balancer"

        sleep 2
        echo -e "${GREEN}✓ Production deployment completed${NC}"
    else
        echo -e "${RED}✗ Deployment cancelled${NC}"
        exit 1
    fi
}

# Function to rollback
rollback() {
    echo -e "${YELLOW}Rolling back to previous version...${NC}"
    echo -e "${BLUE}Mock Rollback Steps:${NC}"
    echo "1. Identify previous stable version"
    echo "2. Stop current container"
    echo "3. Start container with previous image"
    echo "4. Verify deployment"

    sleep 2
    echo -e "${GREEN}✓ Rollback completed${NC}"
}

# Function to health check
health_check() {
    echo -e "${YELLOW}Performing health checks...${NC}"

    # Simulate health check
    for i in {1..3}; do
        echo "Health check attempt $i/3..."
        sleep 1
    done

    echo -e "${GREEN}✓ Health checks passed${NC}"
}

# Main execution
main() {
    check_prerequisites
    build_image
    scan_image

    case $ENVIRONMENT in
        staging)
            deploy_staging
            ;;
        production)
            deploy_production
            ;;
        *)
            echo -e "${RED}Unknown environment: ${ENVIRONMENT}${NC}"
            exit 1
            ;;
    esac

    health_check

    echo -e "${GREEN}=== Deployment Completed Successfully ===${NC}"
}

# Run main function
main
