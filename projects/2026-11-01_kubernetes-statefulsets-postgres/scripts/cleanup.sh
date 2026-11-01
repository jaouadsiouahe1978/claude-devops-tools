#!/bin/bash

set -e

NAMESPACE="postgres-db"

echo "=== Cleaning up PostgreSQL StatefulSet ==="
echo

read -p "This will delete the StatefulSet, PVCs, and namespace. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cleanup cancelled"
  exit 0
fi

echo "1. Deleting StatefulSet..."
kubectl delete statefulset postgres -n $NAMESPACE --ignore-not-found

echo "2. Deleting PersistentVolumeClaims..."
kubectl delete pvc --all -n $NAMESPACE --ignore-not-found

echo "3. Deleting Services..."
kubectl delete svc --all -n $NAMESPACE --ignore-not-found

echo "4. Deleting Namespace..."
kubectl delete namespace $NAMESPACE --ignore-not-found

echo
echo "✓ Cleanup completed!"
