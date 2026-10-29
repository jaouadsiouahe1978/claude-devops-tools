#!/bin/bash
# Script helper pour se connecter à PostgreSQL dans Kubernetes
# Usage: ./connect.sh [namespace] [pod-name] [database] [user]

set -e

NAMESPACE=${1:-postgres-demo}
POD_NAME=${2:-postgres-0}
DATABASE=${3:-postgres}
USER=${4:-postgres}
PORT=5432

echo "🔗 Connexion à PostgreSQL..."
echo "   Namespace: $NAMESPACE"
echo "   Pod: $POD_NAME"
echo "   Database: $DATABASE"
echo "   User: $USER"

# Vérifier que le pod existe
if ! kubectl get pod "$POD_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "❌ Erreur: Pod $POD_NAME non trouvé"
    exit 1
fi

# Attendre que le pod soit ready
echo "⏳ Attente que le pod soit prêt..."
kubectl wait --for=condition=ready pod "$POD_NAME" \
    -n "$NAMESPACE" --timeout=60s || true

# Lancer psql
echo ""
echo "Connecté! (tapez \\q pour quitter)"
echo ""

kubectl exec -it -n "$NAMESPACE" "$POD_NAME" -- \
    psql -U "$USER" -d "$DATABASE"
