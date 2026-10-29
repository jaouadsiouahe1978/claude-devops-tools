#!/bin/bash
# Script de restore PostgreSQL depuis Kubernetes
# Usage: ./restore-postgres.sh [namespace] [pod-name] [backup-file]

set -e

NAMESPACE=${1:-postgres-demo}
POD_NAME=${2:-postgres-0}
BACKUP_DIR="./backups"
BACKUP_FILE=${3}

# Si pas de fichier spécifié, utiliser le plus récent
if [ -z "$BACKUP_FILE" ]; then
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/*.sql 2>/dev/null | head -1 | xargs -I {} basename {})
    if [ -z "$BACKUP_FILE" ]; then
        echo "❌ Erreur: Aucun fichier de backup trouvé dans $BACKUP_DIR"
        exit 1
    fi
fi

BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

echo "🔄 Démarrage du restore PostgreSQL..."
echo "   Namespace: $NAMESPACE"
echo "   Pod: $POD_NAME"
echo "   Backup: $BACKUP_PATH"

# Vérifier que le fichier existe
if [ ! -f "$BACKUP_PATH" ]; then
    echo "❌ Erreur: Fichier $BACKUP_PATH non trouvé"
    exit 1
fi

# Vérifier que le pod existe et est ready
if ! kubectl get pod "$POD_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "❌ Erreur: Pod $POD_NAME non trouvé dans le namespace $NAMESPACE"
    exit 1
fi

# Afficher un avertissement
echo ""
echo "⚠️  ATTENTION: Cette opération va restaurer la base de données depuis le backup"
echo "   Toutes les données actuelles seront écrasées!"
echo ""
read -p "Voulez-vous continuer? (oui/non): " confirmation

if [ "$confirmation" != "oui" ]; then
    echo "❌ Restore annulé"
    exit 0
fi

echo ""
echo "⏳ Restore en cours..."

# Copier le backup dans le pod (en utilisant stdin)
# Note: pg_restore attend le format custom (créé avec --format=custom)
cat "$BACKUP_PATH" | kubectl exec -i -n "$NAMESPACE" "$POD_NAME" -- \
    pg_restore -U postgres --clean --if-exists --verbose /dev/stdin 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Restore réussi!"
    echo ""
    echo "Informations du restore:"
    RESTORE_TIME=$(date)
    echo "   Date: $RESTORE_TIME"
    echo "   Depuis: $BACKUP_PATH"

    # Vérifier les bases de données
    echo ""
    echo "📊 Bases de données après restore:"
    kubectl exec -n "$NAMESPACE" "$POD_NAME" -- \
        psql -U postgres -l | head -10
else
    echo ""
    echo "❌ Erreur lors du restore"
    exit 1
fi
