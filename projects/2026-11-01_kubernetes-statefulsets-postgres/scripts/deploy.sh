#!/bin/bash

set -e

echo "=== Deploying PostgreSQL StatefulSet on Kubernetes ==="
echo

NAMESPACE="postgres-db"

echo "1. Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "2. Creating secret..."
kubectl apply -f ../manifests/secret.yaml

echo "3. Creating configmap..."
kubectl apply -f ../manifests/configmap.yaml

echo "4. Creating storage class..."
kubectl apply -f ../manifests/storageclass.yaml

echo "5. Creating services..."
kubectl apply -f ../manifests/service-headless.yaml
kubectl apply -f ../manifests/service-clusterip.yaml

echo "6. Creating StatefulSet..."
kubectl apply -f ../manifests/statefulset.yaml

echo
echo "=== Waiting for pods to be ready ==="
kubectl rollout status statefulset/postgres -n $NAMESPACE --timeout=5m

echo
echo "=== Deployment Summary ==="
echo "Namespace: $NAMESPACE"
echo
echo "Pods:"
kubectl get pods -n $NAMESPACE

echo
echo "PersistentVolumeClaims:"
kubectl get pvc -n $NAMESPACE

echo
echo "Services:"
kubectl get svc -n $NAMESPACE

echo
echo "✓ PostgreSQL StatefulSet deployed successfully!"
echo
echo "To connect to PostgreSQL:"
echo "  1. Port-forward: kubectl port-forward postgres-0 5432:5432 -n $NAMESPACE"
echo "  2. Connect: psql -h localhost -U postgres -d appdb"
echo
echo "To view logs:"
echo "  kubectl logs postgres-0 -n $NAMESPACE"
