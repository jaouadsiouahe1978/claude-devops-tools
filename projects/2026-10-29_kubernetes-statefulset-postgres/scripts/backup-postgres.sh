#!/bin/bash
# Script de backup PostgreSQL depuis Kubernetes
# Usage: ./backup-postgres.sh [namespace] [pod-name]

set -e

NAMESPACE=${1:-postgres-demo}
POD_NAME=${2:-postgres-0}
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="postgres_backup_${TIMESTAMP}.sql"

# Créer le répertoire de backup
mkdir -p "$BACKUP_DIR"

echo "📦 Démarrage du backup de PostgreSQL..."
echo "   Namespace: $NAMESPACE"
echo "   Pod: $POD_NAME"
echo "   Fichier: $BACKUP_DIR/$BACKUP_FILE"

# Vérifier que le pod existe
if ! kubectl get pod "$POD_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "❌ Erreur: Pod $POD_NAME non trouvé dans le namespace $NAMESPACE"
    exit 1
fi

# Vérifier que le pod est ready
if ! kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q True; then
    echo "⚠️  Attention: Le pod n'est pas en état Ready. Continuação quand même..."
fi

# Effectuer le backup avec pg_dump
echo "⏳ En cours..."
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- \
    pg_dump -U postgres --format=custom --verbose \
    > "$BACKUP_DIR/$BACKUP_FILE" 2>&1

# Vérifier la taille du fichier
BACKUP_SIZE=$(ls -lh "$BACKUP_DIR/$BACKUP_FILE" | awk '{print $5}')

if [ -f "$BACKUP_DIR/$BACKUP_FILE" ] && [ -s "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "✅ Backup réussi!"
    echo "   Fichier: $BACKUP_DIR/$BACKUP_FILE"
    echo "   Taille: $BACKUP_SIZE"

    # Créer un fichier de manifest du backup
    cat > "$BACKUP_DIR/${TIMESTAMP}.manifest" <<EOF
Backup Date: $(date)
Namespace: $NAMESPACE
Pod: $POD_NAME
Filename: $BACKUP_FILE
Size: $BACKUP_SIZE
PostgreSQL Version: $(kubectl exec -n "$NAMESPACE" "$POD_NAME" -- psql -U postgres -c "SELECT version();" 2>/dev/null | head -1 || echo "Unknown")
EOF

    echo "   Manifest: $BACKUP_DIR/${TIMESTAMP}.manifest"
else
    echo "❌ Erreur: Le backup est vide ou n'a pas été créé"
    exit 1
fi

# Afficher les derniers backups
echo ""
echo "📋 Derniers backups:"
ls -lh "$BACKUP_DIR"/*.sql 2>/dev/null | tail -5 || echo "Aucun backup trouvé"
