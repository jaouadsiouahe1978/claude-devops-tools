#!/bin/bash

set -e

echo "🧪 Test du Déploiement Kubernetes"
echo "===================================="

NAMESPACE=${NAMESPACE:-default}
TIMEOUT=300

echo -e "\n[1] Attendre que tous les pods soient prêts..."
kubectl rollout status deployment/app-backend -n $NAMESPACE --timeout=${TIMEOUT}s
kubectl rollout status statefulset/postgres -n $NAMESPACE --timeout=${TIMEOUT}s
kubectl rollout status statefulset/redis -n $NAMESPACE --timeout=${TIMEOUT}s

echo -e "\n[2] Vérifier que tous les pods tournent..."
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running -o json | jq '.items | length')
TOTAL_PODS=$(kubectl get pods -n $NAMESPACE -o json | jq '.items | length')

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
    echo "✓ Tous les pods ($RUNNING_PODS/$TOTAL_PODS) sont en exécution"
else
    echo "❌ Problème avec les pods: $RUNNING_PODS/$TOTAL_PODS en exécution"
    kubectl get pods -n $NAMESPACE
    exit 1
fi

echo -e "\n[3] Vérifier la santé des services..."

# Test PostgreSQL
echo "  Test PostgreSQL..."
POSTGRES_POD=$(kubectl get pod -l app=postgres -n $NAMESPACE -o name | head -1)
if kubectl exec $POSTGRES_POD -n $NAMESPACE -- pg_isready -U postgres > /dev/null; then
    echo "  ✓ PostgreSQL est prêt"
else
    echo "  ❌ PostgreSQL n'est pas prêt"
    exit 1
fi

# Test Redis
echo "  Test Redis..."
REDIS_POD=$(kubectl get pod -l app=redis -n $NAMESPACE -o name | head -1)
if kubectl exec $REDIS_POD -n $NAMESPACE -- redis-cli ping | grep -q PONG; then
    echo "  ✓ Redis est prêt"
else
    echo "  ❌ Redis n'est pas prêt"
    exit 1
fi

# Test Application
echo "  Test Application..."
APP_POD=$(kubectl get pod -l app=app-backend -n $NAMESPACE -o name | head -1)
if kubectl exec $APP_POD -n $NAMESPACE -- wget -O- http://localhost:3000/health > /dev/null 2>&1; then
    echo "  ✓ Application répond aux health checks"
else
    echo "  ❌ Application ne répond pas"
    exit 1
fi

echo -e "\n[4] Vérifier les ressources..."
kubectl top nodes --no-headers 2>/dev/null || echo "  (Metrics non disponibles)"
kubectl top pods -n $NAMESPACE --no-headers 2>/dev/null || echo "  (Metrics non disponibles)"

echo -e "\n[5] Vérifier les PersistentVolumes..."
kubectl get pvc -n $NAMESPACE

echo -e "\n════════════════════════════════════════"
echo "✓ Tous les tests sont passés avec succès!"
echo "════════════════════════════════════════"
