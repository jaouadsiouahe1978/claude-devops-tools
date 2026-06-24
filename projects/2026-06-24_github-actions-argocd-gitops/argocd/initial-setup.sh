#!/bin/bash

##############################################################################
# Configuration initiale d'ArgoCD
#
# Ce script configure:
# - Accès au repositori GitHub
# - Installation de l'application GitOps
# - Configuration du monitoring basique
##############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="argocd"
APP_NAMESPACE="gitops-demo"
REPO_URL="https://github.com/jaouadsiouahe1978/claude-devops-tools"
REPO_PATH="projects/2026-06-24_github-actions-argocd-gitops/k8s"

echo -e "${BLUE}=== ArgoCD Initial Setup ===${NC}"
echo ""

# Vérifier ArgoCD
echo -e "${YELLOW}[1/4] Vérification d'ArgoCD...${NC}"
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    echo -e "${RED}❌ Namespace ArgoCD non trouvé${NC}"
    echo "Exécutez d'abord: ./argocd-install.sh"
    exit 1
fi
echo -e "${GREEN}✅ ArgoCD namespace trouvé${NC}"

# Ajouter le repositori
echo -e "${YELLOW}[2/4] Configuration du repositori Git...${NC}"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-repo-creds
  namespace: ${NAMESPACE}
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: ${REPO_URL}
  password: ''
  username: not-used
EOF

echo -e "${GREEN}✅ Repositori configuré${NC}"

# Créer le namespace de l'app
echo -e "${YELLOW}[3/4] Création du namespace de l'application...${NC}"
kubectl create namespace ${APP_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✅ Namespace ${APP_NAMESPACE} créé${NC}"

# Créer l'application ArgoCD
echo -e "${YELLOW}[4/4] Création de l'application ArgoCD...${NC}"

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-demo-app
  namespace: ${NAMESPACE}
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: main
    path: ${REPO_PATH}
  destination:
    server: https://kubernetes.default.svc
    namespace: ${APP_NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF

echo -e "${GREEN}✅ Application ArgoCD créée${NC}"

echo ""
echo -e "${GREEN}=== Setup terminé ===${NC}"
echo ""
echo -e "${BLUE}Vérifications:${NC}"
echo ""
echo "1. Vérifier l'application ArgoCD:"
echo "   ${YELLOW}kubectl get applications -n ${NAMESPACE}${NC}"
echo ""
echo "2. Voir l'état détaillé:"
echo "   ${YELLOW}kubectl describe app gitops-demo-app -n ${NAMESPACE}${NC}"
echo ""
echo "3. Voir les pods déployés:"
echo "   ${YELLOW}kubectl get pods -n ${APP_NAMESPACE}${NC}"
echo ""
echo "4. Accéder à l'UI ArgoCD:"
echo "   ${YELLOW}kubectl port-forward -n ${NAMESPACE} svc/argocd-server 8080:443${NC}"
echo "   Puis: ${YELLOW}https://localhost:8080${NC}"
echo ""
echo "5. Voir les logs du controller:"
echo "   ${YELLOW}kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=argocd-application-controller --tail=50${NC}"
echo ""
