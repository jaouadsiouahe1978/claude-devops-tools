#!/bin/bash

set -e

echo "============================================"
echo "Installation de cert-manager"
echo "============================================"

# Vérifier si Helm est installé
if ! command -v helm &> /dev/null; then
    echo "❌ Helm n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Créer le namespace
echo "📦 Création du namespace cert-manager..."
kubectl create namespace cert-manager || echo "Namespace déjà existant"

# Ajouter le repo Helm
echo "🔄 Ajout du repo Helm jetstack..."
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Installer cert-manager
echo "🚀 Installation de cert-manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --set global.leaderElection.namespace=cert-manager \
  --wait \
  --timeout 5m

# Vérifier l'installation
echo ""
echo "✅ Installation terminée!"
echo ""
echo "Vérification des pods:"
kubectl get pods -n cert-manager

echo ""
echo "⏳ En attente de la disponibilité de cert-manager..."
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=120s

echo ""
echo "✨ cert-manager est prêt!"
echo ""
echo "Vérifiez les CRDs:"
echo "  kubectl get crds | grep cert-manager"
