#!/bin/bash

set -e

echo "🚀 Multi-Stack Kubernetes Deployment Script"
echo "=============================================="

# Variables
NAMESPACE=${NAMESPACE:-default}
RELEASE_NAME=${RELEASE_NAME:-my-stack}
CHART_PATH="./helm"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifications préalables
echo -e "\n${YELLOW}[1/5]${NC} Vérification des dépendances..."

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} kubectl trouvé"

if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ helm n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} helm trouvé"

# Vérifier la connexion au cluster
echo -e "\n${YELLOW}[2/5]${NC} Vérification de la connexion au cluster Kubernetes..."
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Cluster Kubernetes accessible"
else
    echo -e "${RED}❌ Impossible de se connecter au cluster Kubernetes${NC}"
    exit 1
fi

# Créer le namespace s'il n'existe pas
echo -e "\n${YELLOW}[3/5]${NC} Configuration du namespace..."
if kubectl get namespace $NAMESPACE &> /dev/null; then
    echo -e "${GREEN}✓${NC} Namespace '$NAMESPACE' existe déjà"
else
    echo "Création du namespace '$NAMESPACE'..."
    kubectl create namespace $NAMESPACE
    echo -e "${GREEN}✓${NC} Namespace créé"
fi

# Valider le Helm chart
echo -e "\n${YELLOW}[4/5]${NC} Validation du Helm chart..."
helm lint $CHART_PATH
echo -e "${GREEN}✓${NC} Chart validé"

# Déployer avec Helm
echo -e "\n${YELLOW}[5/5]${NC} Déploiement de l'application..."

helm upgrade --install $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    --values $CHART_PATH/values.yaml \
    --wait \
    --timeout 5m

echo -e "\n${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Déploiement terminé avec succès!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"

# Afficher les infos du déploiement
echo -e "\n📊 État du déploiement:"
kubectl get all -n $NAMESPACE

echo -e "\n🔗 Services disponibles:"
kubectl get svc -n $NAMESPACE

echo -e "\n💾 Stateful Sets:"
kubectl get statefulset -n $NAMESPACE

echo -e "\n🔄 Pods:"
kubectl get pods -n $NAMESPACE

echo -e "\n📝 Pour accéder à l'application:"
echo "  kubectl port-forward svc/app-service 3000:3000 -n $NAMESPACE"
echo ""
echo "  Puis ouvrir: http://localhost:3000"

echo -e "\n📚 Prochaines étapes:"
echo "  • Vérifier les logs: kubectl logs -f deployment/app-backend -n $NAMESPACE"
echo "  • Accéder à PostgreSQL: kubectl port-forward svc/postgres-service 5432:5432 -n $NAMESPACE"
echo "  • Accéder à Redis: kubectl port-forward svc/redis-service 6379:6379 -n $NAMESPACE"
