#!/bin/bash

set -e

NAMESPACE="postgres-db"
POD_NAME="postgres-0"
BACKUP_FILE="${1:-.}"

if [ "$BACKUP_FILE" = "." ] || [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup-file.sql>"
  echo
  echo "Available backups:"
  ls -lah backups/ 2>/dev/null || echo "No backups found"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "=== PostgreSQL Restore Started ==="
echo "Backup File: $BACKUP_FILE"
echo "Target Pod: $POD_NAME"
echo

read -p "This will overwrite the existing database. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Restore cancelled"
  exit 0
fi

echo "Dropping existing database..."
kubectl exec -n $NAMESPACE $POD_NAME -- \
  psql -U postgres --no-password -c "DROP DATABASE IF EXISTS appdb;"

echo "Creating new database..."
kubectl exec -n $NAMESPACE $POD_NAME -- \
  psql -U postgres --no-password -c "CREATE DATABASE appdb OWNER postgres;"

echo "Restoring backup..."
cat "$BACKUP_FILE" | kubectl exec -n $NAMESPACE $POD_NAME -i -- \
  psql -U postgres -d appdb --no-password

echo "✓ Restore completed successfully!"
