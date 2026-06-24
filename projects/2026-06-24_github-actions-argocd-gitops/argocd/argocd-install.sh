#!/bin/bash

##############################################################################
# Script d'installation d'ArgoCD sur Kubernetes
#
# Cet script installe ArgoCD et ses dépendances sur un cluster K8s existant.
# Pré-requis: kubectl configuré et un cluster K8s accessible
##############################################################################

set -e

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Versions
ARGOCD_VERSION="${ARGOCD_VERSION:-v2.8.3}"
NAMESPACE="argocd"

echo -e "${BLUE}=== ArgoCD Installation Script ===${NC}"
echo "ArgoCD Version: ${ARGOCD_VERSION}"
echo "Namespace: ${NAMESPACE}"
echo ""

# Vérifier les prérequis
echo -e "${YELLOW}[1/5] Vérification des prérequis...${NC}"
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ kubectl trouvé${NC}"

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Pas de cluster Kubernetes accessible${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Cluster Kubernetes accessible${NC}"

# Créer le namespace
echo -e "${YELLOW}[2/5] Création du namespace ${NAMESPACE}...${NC}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✅ Namespace créé/mis à jour${NC}"

# Télécharger et installer ArgoCD
echo -e "${YELLOW}[3/5] Installation d'ArgoCD ${ARGOCD_VERSION}...${NC}"
ARGOCD_INSTALL_URL="https://raw.githubusercontent.com/argoproj/argo-cd/release-2.8/manifests/install.yaml"

echo "Téléchargement des manifests depuis: ${ARGOCD_INSTALL_URL}"
if curl -s "${ARGOCD_INSTALL_URL}" | kubectl apply -f - -n ${NAMESPACE}; then
    echo -e "${GREEN}✅ ArgoCD installé${NC}"
else
    echo -e "${RED}❌ Erreur lors de l'installation d'ArgoCD${NC}"
    exit 1
fi

# Attendre que les pods soient prêts
echo -e "${YELLOW}[4/5] Attente du déploiement d'ArgoCD (max 2 minutes)...${NC}"
kubectl rollout status deployment/argocd-server -n ${NAMESPACE} --timeout=2m || true
kubectl rollout status deployment/argocd-repo-server -n ${NAMESPACE} --timeout=2m || true
kubectl rollout status deployment/argocd-application-controller -n ${NAMESPACE} --timeout=2m || true

# Vérifier l'installation
echo -e "${YELLOW}[5/5] Vérification de l'installation...${NC}"
if kubectl get pods -n ${NAMESPACE} | grep -q "argocd-server"; then
    echo -e "${GREEN}✅ ArgoCD est maintenant en cours d'exécution${NC}"
else
    echo -e "${RED}❌ ArgoCD n'est pas complètement déployé${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Installation terminée avec succès ===${NC}"
echo ""
echo -e "${BLUE}Prochaines étapes:${NC}"
echo ""
echo "1. Port-forward vers ArgoCD UI:"
echo "   ${YELLOW}kubectl port-forward -n ${NAMESPACE} svc/argocd-server 8080:443${NC}"
echo ""
echo "2. Accéder à ArgoCD:"
echo "   ${YELLOW}https://localhost:8080${NC}"
echo ""
echo "3. Récupérer le mot de passe admin:"
echo "   ${YELLOW}kubectl get secret -n ${NAMESPACE} argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d${NC}"
echo ""
echo "4. Installer argocd-cli (optionnel):"
echo "   ${YELLOW}curl -sSL https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 -o /usr/local/bin/argocd${NC}"
echo "   ${YELLOW}chmod +x /usr/local/bin/argocd${NC}"
echo ""
echo "5. Voir l'état des ressources ArgoCD:"
echo "   ${YELLOW}kubectl get all -n ${NAMESPACE}${NC}"
echo ""
