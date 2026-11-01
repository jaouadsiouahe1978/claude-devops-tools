#!/bin/bash

set -e

NAMESPACE="postgres-db"
POD_NAME="${1:-postgres-0}"

echo "Connecting to PostgreSQL on pod: $POD_NAME"
echo "Exit with: \q"
echo

kubectl exec -it -n $NAMESPACE $POD_NAME -- \
  psql -U postgres -d appdb
