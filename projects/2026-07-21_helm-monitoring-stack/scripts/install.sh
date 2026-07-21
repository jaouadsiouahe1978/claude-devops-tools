#!/bin/bash

# Script d'installation du Helm Chart Monitoring Stack
# Usage: ./scripts/install.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}
NAMESPACE="monitoring"
RELEASE_NAME="monitoring"

echo "🚀 Installation de Monitoring Stack en environnement: $ENVIRONMENT"

# Vérifier les prérequis
if ! command -v helm &> /dev/null; then
    echo "❌ Helm n'est pas installé. Veuillez installer Helm 3."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl n'est pas installé."
    exit 1
fi

# Vérifier la connexion au cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Impossible de se connecter au cluster Kubernetes."
    exit 1
fi

echo "✅ Prérequis vérifiés"

# Créer le namespace
echo "📦 Création du namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Linter le chart
echo "🔍 Validation du chart..."
helm lint .

# Dry-run
echo "📋 Exécution d'un dry-run..."
if [ "$ENVIRONMENT" = "prod" ]; then
    helm install $RELEASE_NAME . -f values.yaml -f values-prod.yaml \
        --namespace $NAMESPACE --dry-run --debug
else
    helm install $RELEASE_NAME . -f values.yaml -f values-dev.yaml \
        --namespace $NAMESPACE --dry-run --debug
fi

read -p "Voulez-vous continuer avec le déploiement? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Déployer
    echo "🚀 Déploiement en cours..."
    if [ "$ENVIRONMENT" = "prod" ]; then
        helm install $RELEASE_NAME . -f values.yaml -f values-prod.yaml \
            --namespace $NAMESPACE --create-namespace
    else
        helm install $RELEASE_NAME . -f values.yaml -f values-dev.yaml \
            --namespace $NAMESPACE --create-namespace
    fi

    echo "✅ Déploiement terminé!"
    echo ""
    echo "📊 Vérifier le statut:"
    echo "  helm status $RELEASE_NAME --namespace $NAMESPACE"
    echo ""
    echo "📊 Voir les ressources:"
    echo "  kubectl get all -n $NAMESPACE"
    echo ""
    echo "🌐 Accéder aux dashboards (voir port-forward.sh)"
else
    echo "Déploiement annulé."
fi
