#!/bin/bash
set -e

echo "================================"
echo "Kubernetes Persistent Volumes"
echo "================================"
echo ""

if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not running"
    echo "Start with: minikube start --cpus=4 --memory=4096"
    exit 1
fi

echo "✓ Kubernetes cluster is running"
echo ""

echo "📦 Applying Kubernetes manifests..."
echo ""

kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-configmap.yaml
kubectl apply -f 02-secret.yaml
kubectl apply -f 03-pv.yaml
kubectl apply -f 04-pvc.yaml
kubectl apply -f 05-postgres-statefulset.yaml
kubectl apply -f 06-postgres-service.yaml
kubectl apply -f 09-webapp-configmap.yaml
kubectl apply -f 07-webapp-deployment.yaml
kubectl apply -f 08-webapp-service.yaml

echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n devops --timeout=120s 2>/dev/null || true

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Status:"
kubectl get pods -n devops -o wide
echo ""
echo "Next: kubectl port-forward -n devops svc/webapp-service 8080:80"
