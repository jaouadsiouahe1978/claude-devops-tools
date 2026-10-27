#!/bin/bash

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
RELEASE_NAME="${1:-myapp}"
NAMESPACE="${2:-myapp}"
ENVIRONMENT="${3:-dev}"
CHART_PATH="./helm-chart"

echo -e "${YELLOW}🚀 Déploiement MyApp Kubernetes${NC}"
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo "Environment: $ENVIRONMENT"
echo ""

# Vérifier les prérequis
echo -e "${YELLOW}✓ Vérification des prérequis...${NC}"

if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm n'est pas installé${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl n'est pas installé${NC}"
    exit 1
fi

# Créer le namespace
echo -e "${YELLOW}✓ Création du namespace...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Vérifier les images
echo -e "${YELLOW}✓ Vérification des images Docker...${NC}"
docker images | grep -E "myapp-frontend|myapp-api" || {
    echo -e "${YELLOW}⚠ Images Docker non trouvées localement${NC}"
    echo -e "${YELLOW}  Construire les images: docker build -t myapp-frontend:1.0 ./docker/frontend${NC}"
}

# Helm lint
echo -e "${YELLOW}✓ Vérification du chart Helm...${NC}"
helm lint $CHART_PATH

# Déployer avec Helm
echo -e "${YELLOW}✓ Déploiement Helm...${NC}"

VALUES_FILE="$CHART_PATH/values-${ENVIRONMENT}.yaml"

if [ ! -f "$VALUES_FILE" ]; then
    echo -e "${RED}❌ Fichier values manquant: $VALUES_FILE${NC}"
    exit 1
fi

helm upgrade --install $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    -f "$CHART_PATH/values.yaml" \
    -f "$VALUES_FILE" \
    --wait \
    --timeout 5m

# Vérifier le déploiement
echo -e "${YELLOW}✓ Vérification du déploiement...${NC}"
kubectl rollout status deployment/$RELEASE_NAME-frontend -n $NAMESPACE --timeout=5m
kubectl rollout status deployment/$RELEASE_NAME-api -n $NAMESPACE --timeout=5m

# Afficher le statut
echo -e "${GREEN}✅ Déploiement réussi!${NC}"
echo ""
echo -e "${YELLOW}Pods:${NC}"
kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"

echo ""
echo -e "${YELLOW}Services:${NC}"
kubectl get svc -n $NAMESPACE

echo ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "1. Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-frontend 8080:80"
echo "2. Visiter: http://localhost:8080"
echo "3. Logs: kubectl logs -f -n $NAMESPACE deployment/$RELEASE_NAME-frontend"

echo ""
echo -e "${GREEN}✓ Déploiement terminé!${NC}"
