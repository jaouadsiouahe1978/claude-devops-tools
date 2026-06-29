#!/bin/bash

set -e

echo "🚀 Kubernetes + Helm Deployment Script"
echo "========================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}[1/6] Checking prerequisites...${NC}"
command -v kubectl &> /dev/null || { echo "kubectl not found"; exit 1; }
command -v helm &> /dev/null || { echo "helm not found"; exit 1; }
echo -e "${GREEN}✓ kubectl and helm installed${NC}"

# Start Minikube if not running
echo -e "${BLUE}[2/6] Ensuring Minikube is running...${NC}"
if ! minikube status | grep -q "Running"; then
    echo "Starting Minikube..."
    minikube start --cpus=2 --memory=3072 --driver=docker
else
    echo -e "${GREEN}✓ Minikube already running${NC}"
fi

eval $(minikube docker-env)

# Build Docker images
echo -e "${BLUE}[3/6] Building Docker images...${NC}"
cd docker/frontend
docker build -t myapp/frontend:1.0 .
cd ../backend
docker build -t myapp/backend:1.0 .
cd ../..
echo -e "${GREEN}✓ Docker images built${NC}"

# Load images into Minikube
echo -e "${BLUE}[4/6] Loading images into Minikube...${NC}"
minikube image load myapp/frontend:1.0
minikube image load myapp/backend:1.0
echo -e "${GREEN}✓ Images loaded${NC}"

# Enable Ingress addon
echo -e "${BLUE}[5/6] Enabling Ingress controller...${NC}"
minikube addons enable ingress
sleep 5
echo -e "${GREEN}✓ Ingress enabled${NC}"

# Deploy with Helm
echo -e "${BLUE}[6/6] Deploying with Helm...${NC}"

# Create namespace if needed
kubectl create namespace default --dry-run=client -o yaml | kubectl apply -f -

# Helm install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm dependency update ./helm/myapp

helm upgrade --install myapp ./helm/myapp \
    --values ./helm/myapp/values.yaml \
    --namespace default \
    --wait \
    --timeout 5m

echo -e "${GREEN}✓ Helm deployment complete${NC}"

# Wait for pods
echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=myapp -n default --timeout=300s

# Show deployment status
echo -e "\n${GREEN}========== DEPLOYMENT STATUS ==========${NC}"
kubectl get all -n default

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo -e "\n${GREEN}========== ACCESS INFORMATION ==========${NC}"
echo -e "Minikube IP: ${BLUE}${MINIKUBE_IP}${NC}"
echo -e "Frontend URL: ${BLUE}http://${MINIKUBE_IP}${NC}"
echo -e "\nAdd to /etc/hosts:"
echo -e "  ${MINIKUBE_IP} web.local"

echo -e "\n${GREEN}========== USEFUL COMMANDS ==========${NC}"
echo "# View logs"
echo "  kubectl logs -f deployment/myapp-frontend"
echo "  kubectl logs -f deployment/myapp-backend"
echo ""
echo "# Port forward"
echo "  kubectl port-forward svc/myapp-frontend 8080:80"
echo "  kubectl port-forward svc/myapp-backend 5000:5000"
echo ""
echo "# Helm commands"
echo "  helm list"
echo "  helm status myapp"
echo "  helm values myapp"
echo ""
echo "# Cleanup"
echo "  helm uninstall myapp"

echo -e "\n${GREEN}✅ Deployment successful!${NC}"
