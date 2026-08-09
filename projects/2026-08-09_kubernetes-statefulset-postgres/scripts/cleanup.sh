#!/bin/bash

# ============================================================================
# Script: cleanup.sh
# Description: Nettoyer toutes les ressources du projet
# Usage: bash scripts/cleanup.sh
# ============================================================================

set -e

echo "🧹 Nettoyage des ressources Kubernetes..."
echo ""

# Supprimer le StatefulSet
echo "Suppression du StatefulSet..."
kubectl delete statefulset postgres -n postgresql 2>/dev/null || echo "   (pas trouvé)"

# Supprimer les Services
echo "Suppression des Services..."
kubectl delete service postgres -n postgresql 2>/dev/null || echo "   (pas trouvé)"
kubectl delete service postgres-external -n postgresql 2>/dev/null || echo "   (pas trouvé)"

# Supprimer les PersistentVolumeClaims
echo "Suppression des PersistentVolumeClaims..."
kubectl delete pvc -n postgresql --all 2>/dev/null || echo "   (aucun PVC trouvé)"

# Supprimer les Secrets et ConfigMaps
echo "Suppression des Secrets et ConfigMaps..."
kubectl delete secret postgres-secret -n postgresql 2>/dev/null || echo "   (pas trouvé)"
kubectl delete configmap postgres-config -n postgresql 2>/dev/null || echo "   (pas trouvé)"

# Supprimer le namespace
echo "Suppression du namespace postgresql..."
kubectl delete namespace postgresql 2>/dev/null || echo "   (pas trouvé)"

# Nettoyer les PersistentVolumes (optionnel)
echo ""
echo "⚠️  Les PersistentVolumes (pv-0, pv-1) ne sont pas supprimés automatiquement."
echo "   Pour les supprimer manuellement:"
echo "   kubectl delete pv pv-0 pv-1"
echo ""
echo "   Pour nettoyer les données locales sur le node:"
echo "   minikube ssh"
echo "   sudo rm -rf /data/pv-0/* /data/pv-1/*"

echo ""
echo "✅ Nettoyage terminé!"
