#!/bin/bash

# ============================================================================
# Script: monitor.sh
# Description: Monitorer le StatefulSet et les ressources en temps réel
# Usage: bash scripts/monitor.sh
# ============================================================================

NAMESPACE="postgresql"

echo "🔍 Monitoring du StatefulSet PostgreSQL"
echo "========================================"
echo ""

# Fonction pour afficher un titre de section
print_section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Afficher les StatefulSets
print_section "StatefulSets"
kubectl get statefulset -n $NAMESPACE -o wide

# Afficher les Pods
print_section "Pods (en temps réel, appuyer sur Ctrl+C pour arrêter)"
kubectl get pods -n $NAMESPACE -o wide -w
