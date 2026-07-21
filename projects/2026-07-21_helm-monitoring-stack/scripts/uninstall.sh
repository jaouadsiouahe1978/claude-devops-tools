#!/bin/bash

# Script de suppression du Helm Chart Monitoring Stack
# Usage: ./scripts/uninstall.sh

set -e

NAMESPACE="monitoring"
RELEASE_NAME="monitoring"

echo "🗑️  Suppression de Monitoring Stack..."

# Vérifier les prérequis
if ! command -v helm &> /dev/null; then
    echo "❌ Helm n'est pas installé."
    exit 1
fi

# Vérifier la connexion au cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Impossible de se connecter au cluster Kubernetes."
    exit 1
fi

# Lister les releases
echo "📋 Releases actuelles:"
helm list -n $NAMESPACE || true

read -p "Êtes-vous sûr de vouloir supprimer la release '$RELEASE_NAME' ? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Suppression de la release..."
    helm uninstall $RELEASE_NAME --namespace $NAMESPACE

    read -p "Voulez-vous également supprimer le namespace '$NAMESPACE' ? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Suppression du namespace..."
        kubectl delete namespace $NAMESPACE
    fi

    echo "✅ Suppression terminée!"
else
    echo "Suppression annulée."
fi
