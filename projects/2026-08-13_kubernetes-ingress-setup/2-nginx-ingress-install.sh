#!/bin/bash

set -e

echo "============================================"
echo "Installation du NGINX Ingress Controller"
echo "============================================"

# Vérifier si Helm est installé
if ! command -v helm &> /dev/null; then
    echo "❌ Helm n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Créer le namespace
echo "📦 Création du namespace ingress-nginx..."
kubectl create namespace ingress-nginx || echo "Namespace déjà existant"

# Ajouter le repo Helm
echo "🔄 Ajout du repo Helm ingress-nginx..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Installer NGINX Ingress Controller
echo "🚀 Installation du NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=false \
  --wait \
  --timeout 5m

# Vérifier l'installation
echo ""
echo "✅ Installation terminée!"
echo ""
echo "Vérification des pods:"
kubectl get pods -n ingress-nginx

echo ""
echo "Service LoadBalancer:"
kubectl get svc -n ingress-nginx

echo ""
echo "⏳ En attente de l'IP externe (peut prendre quelques secondes)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo ""
echo "✨ NGINX Ingress Controller est prêt!"
echo ""
echo "Obtenez l'IP externe avec:"
echo "  kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
