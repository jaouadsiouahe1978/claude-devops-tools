#!/bin/bash

set -e

NAMESPACE="postgres-db"
POD_NAME="postgres-0"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/postgres_backup_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "=== PostgreSQL Backup Started ==="
echo "Target Pod: $POD_NAME"
echo "Backup File: $BACKUP_FILE"
echo

echo "Creating backup..."
kubectl exec -n $NAMESPACE $POD_NAME -- \
  pg_dump -U postgres -d appdb --no-password > "$BACKUP_FILE"

FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "✓ Backup completed successfully!"
echo "File size: $FILE_SIZE"
echo "Location: $(readlink -f $BACKUP_FILE)"

ls -lah "$BACKUP_FILE"
