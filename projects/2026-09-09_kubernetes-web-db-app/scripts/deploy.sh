#!/bin/bash
set -euo pipefail

NAMESPACE="webapp"

echo "Creating namespace..."
kubectl create namespace $NAMESPACE 2>/dev/null || true
kubectl config set-context --current --namespace=$NAMESPACE

echo "Creating secrets..."
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=appuser \
  --from-literal=DB_PASSWORD=SecurePass123! \
  --from-literal=DB_NAME=appdb \
  -n $NAMESPACE 2>/dev/null || true

echo "Deploying resources..."
kubectl apply -f manifests/all-resources.yaml

echo "Waiting for deployments..."
sleep 10

echo "✅ Deployment complete!"
echo ""
echo "Useful commands:"
echo "  kubectl port-forward svc/nginx-service 8080:80 -n $NAMESPACE"
echo "  curl http://localhost:8080/"
echo "  curl http://localhost:8080/api/users"
echo "  kubectl logs -f deployment/api-deployment -n $NAMESPACE"
