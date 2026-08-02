#!/bin/bash
set -e

CLUSTER_NAME="devops-ingress"
NAMESPACE="devops-app"

echo "======================================"
echo "Kubernetes Ingress Setup Script"
echo "======================================"
echo ""

# Step 1: Create cluster
echo "[1/6] Creating Kind cluster..."
if kind get clusters | grep -q $CLUSTER_NAME; then
  echo "⚠ Cluster already exists. Skipping creation."
else
  kind create cluster --name $CLUSTER_NAME --config kind-cluster-config.yaml
  echo "✓ Cluster created"
fi
echo ""

# Step 2: Verify cluster
echo "[2/6] Verifying cluster..."
kubectl cluster-info
kubectl get nodes
echo "✓ Cluster verified"
echo ""

# Step 3: Install Ingress Controller
echo "[3/6] Installing NGINX Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

if helm list -n ingress-nginx | grep -q "nginx-ingress"; then
  echo "⚠ Ingress Controller already installed. Skipping."
else
  helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.service.type=LoadBalancer \
    --set controller.metrics.enabled=true
  echo "✓ Ingress Controller installed"
fi
echo ""

# Step 4: Install cert-manager
echo "[4/6] Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update

if helm list -n cert-manager | grep -q "cert-manager"; then
  echo "⚠ cert-manager already installed. Skipping."
else
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true

  echo "⏳ Waiting for cert-manager to be ready..."
  kubectl wait --for=condition=available --timeout=300s \
    deployment/cert-manager -n cert-manager || true
  echo "✓ cert-manager installed"
fi
echo ""

# Step 5: Deploy applications
echo "[5/6] Deploying applications..."
kubectl apply -f cert-issuer.yaml
kubectl apply -f manifests/

echo "⏳ Waiting for deployments..."
kubectl rollout status deployment -n $NAMESPACE --timeout=120s || true
echo "✓ Applications deployed"
echo ""

# Step 6: Deploy Ingress rules
echo "[6/6] Deploying Ingress rules..."
kubectl apply -f ingress-rules.yaml
echo "✓ Ingress rules deployed"
echo ""

echo "======================================"
echo "✓ Setup Complete!"
echo "======================================"
echo ""
echo "Cluster Details:"
kubectl get nodes -o wide
echo ""
echo "Ingress Controller Status:"
kubectl get svc -n ingress-nginx
echo ""
echo "Next steps:"
echo "1. Port-forward to Ingress (Kind doesn't support LoadBalancer):"
echo "   kubectl port-forward -n ingress-nginx svc/nginx-ingress-ingress-nginx-controller 80:80 443:443 &"
echo ""
echo "2. Add hosts to /etc/hosts:"
echo "   echo '127.0.0.1 app.local api.local echo.local services.local' | sudo tee -a /etc/hosts"
echo ""
echo "3. Test the services:"
echo "   ./test-ingress.sh"
echo ""
echo "4. View logs:"
echo "   kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f"
