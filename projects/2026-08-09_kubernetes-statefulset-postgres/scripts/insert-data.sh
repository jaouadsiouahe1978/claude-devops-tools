#!/bin/bash

# ============================================================================
# Script: insert-data.sh
# Description: Insérer des données de test dans PostgreSQL
# Usage: bash scripts/insert-data.sh
# ============================================================================

set -e

NAMESPACE="postgresql"
POD_NAME="postgres-0"
DB_NAME="myapp"

echo "🔄 Insertion de données de test..."

# Insérer des données dans la table users
kubectl exec -it $POD_NAME -n $NAMESPACE -- psql -U postgres -d $DB_NAME << SQL
INSERT INTO users (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob', 'bob@example.com'),
  ('Charlie', 'charlie@example.com'),
  ('Diana', 'diana@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO logs (message, level) VALUES
  ('Application started', 'INFO'),
  ('Database connection established', 'INFO'),
  ('Processing batch 1', 'DEBUG'),
  ('Batch processing completed', 'INFO')
ON CONFLICT DO NOTHING;

SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as log_count FROM logs;
SQL

echo "✅ Données insérées avec succès!"
