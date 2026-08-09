#!/bin/bash

# ============================================================================
# Script: check-data.sh
# Description: Vérifier les données persistes après un crash de pod
# Usage: bash scripts/check-data.sh
# ============================================================================

set -e

NAMESPACE="postgresql"
POD_NAME="postgres-0"
DB_NAME="myapp"

echo "🔍 Vérification des données..."

# Vérifier les données dans la table users
kubectl exec -it $POD_NAME -n $NAMESPACE -- psql -U postgres -d $DB_NAME << SQL
\echo '--- Table USERS ---'
SELECT * FROM users;

\echo ''
\echo '--- Table LOGS ---'
SELECT * FROM logs;

\echo ''
\echo '--- Statistiques ---'
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_logs FROM logs;
SQL

echo "✅ Vérification complétée!"
