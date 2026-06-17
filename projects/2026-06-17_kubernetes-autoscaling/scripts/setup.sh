#!/bin/bash
#
# Script de setup pour préparer l'environnement
# Installe metrics-server et déploie l'application
#

set -e

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Kubernetes Autoscaling Project Setup ===${NC}"
echo ""

# Vérifier kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}[!] kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] kubectl found${NC}"

# Vérifier la connexion au cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}[!] Cannot connect to Kubernetes cluster${NC}"
    echo "Please configure kubectl to connect to your cluster"
    exit 1
fi

echo -e "${GREEN}[✓] Connected to Kubernetes cluster${NC}"
CLUSTER=$(kubectl config current-context)
echo "Current context: $CLUSTER"
echo ""

# Installer metrics-server
echo -e "${YELLOW}[*] Checking metrics-server installation...${NC}"

if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo -e "${GREEN}[✓] metrics-server is already installed${NC}"
else
    echo -e "${YELLOW}[*] Installing metrics-server...${NC}"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

    echo -e "${YELLOW}[*] Waiting for metrics-server to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system

    echo -e "${GREEN}[✓] metrics-server installed and ready${NC}"
fi
echo ""

# Créer une namespace optionnelle
read -p "Create a new namespace for this project? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    NAMESPACE="devops-autoscaling"
    echo -e "${YELLOW}[*] Creating namespace: $NAMESPACE${NC}"
    kubectl create namespace $NAMESPACE || true
    kubectl label namespace $NAMESPACE name=$NAMESPACE || true
    echo -e "${GREEN}[✓] Namespace created${NC}"
    echo ""
else
    NAMESPACE="default"
    echo "Using default namespace"
fi

# Copier les fichiers k8s et adapter le namespace
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_DIR="$PROJECT_DIR/k8s"

echo -e "${YELLOW}[*] Project directory: $PROJECT_DIR${NC}"
echo ""

# Créer la Docker image (si disponible)
echo -e "${YELLOW}[*] Checking if Docker image exists...${NC}"

if docker images | grep -q "devops-app.*1.0"; then
    echo -e "${GREEN}[✓] Docker image 'devops-app:1.0' already exists${NC}"
else
    echo -e "${YELLOW}[!] Docker image not found${NC}"
    read -p "Build Docker image now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Building Docker image...${NC}"
        cd "$PROJECT_DIR/docker"
        docker build -t devops-app:1.0 .
        echo -e "${GREEN}[✓] Docker image built${NC}"
    fi
fi
echo ""

# Déployer l'application
echo -e "${YELLOW}[*] Deploying application...${NC}"

# Adapter le namespace dans les manifests
sed "s/namespace: default/namespace: $NAMESPACE/g" "$K8S_DIR/deployment.yaml" | kubectl apply -f -
kubectl apply -f "$K8S_DIR/hpa.yaml" --namespace=$NAMESPACE

echo -e "${GREEN}[✓] Application deployed${NC}"
echo ""

# Attendre que le déploiement soit prêt
echo -e "${YELLOW}[*] Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/devops-app -n $NAMESPACE

echo -e "${GREEN}[✓] Deployment is ready${NC}"
echo ""

# Afficher le statut
echo -e "${YELLOW}[*] Deployment Status:${NC}"
kubectl get deployment devops-app -n $NAMESPACE
echo ""

echo -e "${YELLOW}[*] Pods:${NC}"
kubectl get pods -l app=devops-app -n $NAMESPACE
echo ""

echo -e "${YELLOW}[*] HPA Status:${NC}"
kubectl get hpa -n $NAMESPACE
echo ""

# Instructions finales
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Forward the service port:"
echo -e "   ${BLUE}kubectl port-forward svc/devops-app 5000:5000 -n $NAMESPACE${NC}"
echo ""
echo "2. In another terminal, start monitoring:"
echo -e "   ${BLUE}./scripts/monitor.sh${NC}"
echo ""
echo "3. Generate load to trigger autoscaling:"
echo -e "   ${BLUE}./scripts/test-load.sh 5 5${NC}"
echo ""
echo "4. Watch the HPA in action:"
echo -e "   ${BLUE}kubectl get hpa -n $NAMESPACE -w${NC}"
echo "   ${BLUE}kubectl get pods -n $NAMESPACE -w${NC}"
echo ""

echo -e "${YELLOW}Useful commands:${NC}"
echo "  kubectl get nodes                            # List nodes"
echo "  kubectl top nodes                            # Node resources"
echo "  kubectl top pods -n $NAMESPACE                # Pod resources"
echo "  kubectl logs deployment/devops-app -n $NAMESPACE  # View logs"
echo "  kubectl describe hpa -n $NAMESPACE           # HPA details"
echo ""
