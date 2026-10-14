#!/bin/bash
# Script d'installation et configuration d'ArgoCD
set -e

echo "=== Installation d'ArgoCD ==="

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[1/6]${NC} Création du namespace argocd..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}[2/6]${NC} Installation des composants ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${BLUE}[3/6]${NC} Attente du démarrage des pods ArgoCD..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=5m
kubectl rollout status deployment/argocd-application-controller -n argocd --timeout=5m

echo -e "${BLUE}[4/6]${NC} Configuration du port-forward..."
pkill -f "kubectl port-forward svc/argocd-server" || true
sleep 2
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
PF_PID=$!
echo "Port-forward lancé (PID: $PF_PID)"

echo -e "${BLUE}[5/6]${NC} Récupération des credentials..."
sleep 3
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

echo -e "${GREEN}✓ Installation complète!${NC}"
echo ""
echo "=== Accès à ArgoCD ==="
echo "URL: https://localhost:8080"
echo "Login: admin"
echo "Password: $PASSWORD"
