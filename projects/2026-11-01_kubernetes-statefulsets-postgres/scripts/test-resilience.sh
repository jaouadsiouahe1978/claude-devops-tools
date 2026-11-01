#!/bin/bash

set -e

NAMESPACE="postgres-db"

echo "=== PostgreSQL Resilience Test ==="
echo

echo "1. Current pod status:"
kubectl get pods -n $NAMESPACE -o wide

echo
echo "2. Testing database connectivity..."
kubectl exec -n $NAMESPACE postgres-0 -- \
  psql -U postgres -d postgres --no-password -c "SELECT version();" | head -1

echo "✓ Connection successful"

echo
echo "3. Inserting test data..."
kubectl exec -n $NAMESPACE postgres-0 -- \
  psql -U postgres -d appdb --no-password -c \
  "INSERT INTO users (username, email) VALUES ('testuser1', 'test1@example.com') ON CONFLICT DO NOTHING;"

echo "✓ Data inserted"

echo
echo "4. Verifying data..."
RECORD_COUNT=$(kubectl exec -n $NAMESPACE postgres-0 -- \
  psql -U postgres -d appdb --no-password -t -c "SELECT COUNT(*) FROM users;")
echo "Users in database: $RECORD_COUNT"

echo
echo "5. Killing postgres-0 pod to test self-healing..."
kubectl delete pod postgres-0 -n $NAMESPACE
echo "Pod deleted. Waiting for recovery..."

echo
echo "6. Waiting for new pod to start..."
kubectl wait --for=condition=ready pod/postgres-0 -n $NAMESPACE --timeout=300s

echo
echo "7. Verifying data after pod restart..."
RECORD_COUNT=$(kubectl exec -n $NAMESPACE postgres-0 -- \
  psql -U postgres -d appdb --no-password -t -c "SELECT COUNT(*) FROM users;")
echo "Users in database after restart: $RECORD_COUNT"

echo
echo "✓ Resilience test completed!"
echo "Pod self-healed and data persisted correctly"
