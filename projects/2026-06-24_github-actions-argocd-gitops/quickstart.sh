#!/bin/bash

##############################################################################
# Quick Start Script - GitOps avec GitHub Actions et ArgoCD
#
# Ce script automatise la mise en place complète du projet en 5-10 minutes
##############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     GitOps with GitHub Actions & ArgoCD - Quick Start      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Étape 0: Vérifications
echo -e "${YELLOW}[0/4] Vérification des pré-requis...${NC}"

MISSING_TOOLS=0

if ! command -v docker &> /dev/null; then
    echo -e "${RED}  ❌ Docker n'est pas installé${NC}"
    MISSING_TOOLS=1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}  ❌ kubectl n'est pas installé${NC}"
    MISSING_TOOLS=1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}  ❌ git n'est pas installé${NC}"
    MISSING_TOOLS=1
fi

if [ $MISSING_TOOLS -eq 1 ]; then
    echo -e "${RED}Veuillez installer les outils manquants et relancer le script${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Docker${NC}"
echo -e "${GREEN}  ✅ kubectl${NC}"
echo -e "${GREEN}  ✅ git${NC}"

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${YELLOW}  ⚠️  Pas de cluster K8s détecté${NC}"
    echo -e "${YELLOW}  → Veuillez démarrer Minikube ou un autre cluster K8s:${NC}"
    echo -e "${YELLOW}     minikube start${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}  ✅ Cluster Kubernetes accessible${NC}"
echo ""

# Étape 1: Construire l'image Docker
echo -e "${YELLOW}[1/4] Construction de l'image Docker...${NC}"

if docker build -f "${PROJECT_DIR}/app/Dockerfile" \
    -t gitops-app:local \
    -t gitops-app:latest \
    "${PROJECT_DIR}"; then
    echo -e "${GREEN}  ✅ Image Docker construite avec succès${NC}"
else
    echo -e "${RED}  ❌ Erreur lors de la construction de l'image Docker${NC}"
    exit 1
fi
echo ""

# Étape 2: Installer ArgoCD
echo -e "${YELLOW}[2/4] Installation d'ArgoCD...${NC}"

if [ -f "${PROJECT_DIR}/argocd/argocd-install.sh" ]; then
    bash "${PROJECT_DIR}/argocd/argocd-install.sh"
else
    echo -e "${RED}  ❌ Script d'installation non trouvé${NC}"
    exit 1
fi
echo ""

# Étape 3: Configuration initiale
echo -e "${YELLOW}[3/4] Configuration initiale d'ArgoCD...${NC}"

if [ -f "${PROJECT_DIR}/argocd/initial-setup.sh" ]; then
    bash "${PROJECT_DIR}/argocd/initial-setup.sh"
else
    echo -e "${RED}  ❌ Script de configuration non trouvé${NC}"
    exit 1
fi
echo ""

# Étape 4: Attendre les pods
echo -e "${YELLOW}[4/4] Attente du déploiement complet (1-2 minutes)...${NC}"

echo "Pods de gitops-demo:"
kubectl wait --for=condition=ready pod \
    -l app=gitops-app \
    -n gitops-demo \
    --timeout=120s || echo -e "${YELLOW}⚠️  Timeout: les pods se déploient encore${NC}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ Setup Terminé!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📋 Résumé:${NC}"
echo "  • Application Docker: ${GREEN}gitops-app:latest${NC}"
echo "  • ArgoCD Namespace: ${GREEN}argocd${NC}"
echo "  • App Namespace: ${GREEN}gitops-demo${NC}"
echo ""

echo -e "${BLUE}🔗 Accès à l'application:${NC}"
echo ""
echo "  1. Forwarding vers le service:"
echo "     ${YELLOW}kubectl port-forward -n gitops-demo svc/gitops-app 5000:80${NC}"
echo ""
echo "  2. Tester l'endpoint dans un autre terminal:"
echo "     ${YELLOW}curl http://localhost:5000/health${NC}"
echo ""

echo -e "${BLUE}📊 Accès à ArgoCD UI:${NC}"
echo ""
echo "  1. Forwarding vers ArgoCD:"
echo "     ${YELLOW}kubectl port-forward -n argocd svc/argocd-server 8080:443${NC}"
echo ""
echo "  2. Ouvrir dans le navigateur:"
echo "     ${YELLOW}https://localhost:8080${NC}"
echo ""
echo "  3. Password admin:"
echo "     ${YELLOW}kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d${NC}"
echo ""

echo -e "${BLUE}📚 Prochaines étapes:${NC}"
echo ""
echo "  • Lire: ${YELLOW}GITOPS_GUIDE.md${NC} (guide complet)"
echo "  • Lancer: ${YELLOW}./app/server.py${NC} (tester localement)"
echo "  • Modifier: ${YELLOW}app/server.py${NC} et commiter pour tester le pipeline"
echo ""

echo -e "${BLUE}🐛 Dépannage:${NC}"
echo ""
echo "  Voir les pods:"
echo "    ${YELLOW}kubectl get pods -n gitops-demo${NC}"
echo ""
echo "  Voir les logs:"
echo "    ${YELLOW}kubectl logs -n gitops-demo -l app=gitops-app${NC}"
echo ""
echo "  Voir l'état ArgoCD:"
echo "    ${YELLOW}kubectl get application -n argocd${NC}"
echo ""
