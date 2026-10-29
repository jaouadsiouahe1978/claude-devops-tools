#!/bin/bash
# Script de déploiement complet de PostgreSQL StatefulSet
# Usage: ./deploy.sh [namespace] [action]
# Actions: deploy, undeploy, status, logs, port-forward

set -e

NAMESPACE=${1:-postgres-demo}
ACTION=${2:-deploy}
POD_NAME="postgres-0"

case "$ACTION" in
    deploy)
        echo "🚀 Déploiement de PostgreSQL StatefulSet..."

        # Créer le namespace
        if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
            echo "📁 Création du namespace: $NAMESPACE"
            kubectl create namespace "$NAMESPACE"
        fi

        # Créer le secret
        echo "🔑 Création du secret..."
        kubectl create secret generic postgres-secret \
            --from-literal=POSTGRES_PASSWORD=mysecurepassword123 \
            -n "$NAMESPACE" \
            --dry-run=client -o yaml | kubectl apply -f -

        # Appliquer les manifests
        echo "📋 Application des manifests..."
        kubectl apply -f configmap.yaml
        kubectl apply -f service.yaml
        kubectl apply -f statefulset.yaml

        # Attendre que le pod soit prêt
        echo "⏳ Attente du déploiement..."
        kubectl rollout status statefulset/postgres -n "$NAMESPACE" --timeout=5m

        echo "✅ Déploiement réussi!"
        echo ""
        echo "Prochaines étapes:"
        echo "  1. Port forward: kubectl port-forward -n $NAMESPACE $POD_NAME 5432:5432"
        echo "  2. Connexion: ./scripts/connect.sh"
        echo "  3. Vérifier: kubectl get all -n $NAMESPACE"
        ;;

    undeploy)
        echo "🗑️  Suppression de PostgreSQL StatefulSet..."

        read -p "Êtes-vous sûr? (oui/non): " confirm
        if [ "$confirm" != "oui" ]; then
            echo "❌ Annulation"
            exit 0
        fi

        kubectl delete statefulset postgres -n "$NAMESPACE" --ignore-not-found
        kubectl delete svc postgres postgres-service postgres-nodeport -n "$NAMESPACE" --ignore-not-found
        kubectl delete configmap postgres-config -n "$NAMESPACE" --ignore-not-found
        kubectl delete secret postgres-secret -n "$NAMESPACE" --ignore-not-found

        # Optionnel: supprimer le namespace
        read -p "Supprimer aussi le namespace $NAMESPACE? (oui/non): " confirm_ns
        if [ "$confirm_ns" = "oui" ]; then
            kubectl delete namespace "$NAMESPACE"
            echo "✅ Namespace supprimé"
        fi

        echo "✅ Suppression réussie"
        ;;

    status)
        echo "📊 Status de PostgreSQL..."
        echo ""
        echo "=== StatefulSet ==="
        kubectl get statefulset postgres -n "$NAMESPACE" || echo "StatefulSet non trouvé"

        echo ""
        echo "=== Pods ==="
        kubectl get pods -l app=postgres -n "$NAMESPACE" -o wide

        echo ""
        echo "=== Services ==="
        kubectl get svc -l app=postgres -n "$NAMESPACE"

        echo ""
        echo "=== PersistentVolumeClaims ==="
        kubectl get pvc -n "$NAMESPACE" | grep postgres || echo "Aucun PVC trouvé"

        echo ""
        echo "=== Détails du pod ==="
        kubectl describe pod "$POD_NAME" -n "$NAMESPACE" 2>/dev/null | head -30 || echo "Pod non trouvé"
        ;;

    logs)
        echo "📝 Logs de PostgreSQL..."
        kubectl logs -f "$POD_NAME" -n "$NAMESPACE" --tail=50
        ;;

    port-forward)
        echo "🌉 Port forward: localhost:5432 -> $POD_NAME:5432"
        echo "Appuyez sur Ctrl+C pour arrêter"
        kubectl port-forward -n "$NAMESPACE" "$POD_NAME" 5432:5432
        ;;

    events)
        echo "📋 Événements Kubernetes..."
        kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -20
        ;;

    *)
        echo "Usage: $0 [namespace] [action]"
        echo ""
        echo "Actions disponibles:"
        echo "  deploy       - Déployer PostgreSQL"
        echo "  undeploy     - Supprimer PostgreSQL"
        echo "  status       - Afficher le status"
        echo "  logs         - Afficher les logs"
        echo "  port-forward - Port forward local"
        echo "  events       - Afficher les événements"
        echo ""
        echo "Exemples:"
        echo "  $0 postgres-demo deploy"
        echo "  $0 postgres-demo status"
        echo "  $0 postgres-demo logs"
        exit 1
        ;;
esac
