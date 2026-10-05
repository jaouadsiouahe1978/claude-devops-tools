#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_DIR="$PROJECT_DIR/k8s"

echo "🚀 Deploying application to Kubernetes..."
echo ""

# Check if minikube is running
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster not accessible. Please start minikube:"
    echo "   minikube start"
    exit 1
fi

# Create namespace
echo "📍 Creating namespace..."
kubectl apply -f "$K8S_DIR/namespace.yaml"
echo "✓ Namespace created"
echo ""

# Create ConfigMap and Secrets
echo "⚙️  Creating configuration..."
kubectl apply -f "$K8S_DIR/configmap.yaml"
kubectl apply -f "$K8S_DIR/secret.yaml"
echo "✓ Configuration created"
echo ""

# Create PVC
echo "💾 Creating persistent storage..."
kubectl apply -f "$K8S_DIR/pvc.yaml"
echo "✓ Storage created"
echo ""

# Deploy MySQL
echo "🗄️  Deploying MySQL database..."
kubectl apply -f "$K8S_DIR/mysql-deployment.yaml"
echo "✓ MySQL deployed"
echo ""

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=available --timeout=120s \
  deployment/mysql-deployment -n app-namespace || echo "⚠️  MySQL still starting..."
sleep 5
echo ""

# Deploy Flask API
echo "🔧 Deploying Flask API..."
kubectl apply -f "$K8S_DIR/flask-deployment.yaml"
echo "✓ Flask API deployed"
echo ""

# Wait for Flask to be ready
echo "⏳ Waiting for Flask API to be ready..."
kubectl wait --for=condition=available --timeout=120s \
  deployment/flask-app -n app-namespace || echo "⚠️  Flask API still starting..."
echo ""

# Deploy Nginx frontend
echo "🌐 Deploying Nginx frontend..."
kubectl apply -f "$K8S_DIR/nginx-deployment.yaml"
echo "✓ Nginx frontend deployed"
echo ""

# Create Services
echo "🔌 Creating services..."
kubectl apply -f "$K8S_DIR/services.yaml"
echo "✓ Services created"
echo ""

# Create Ingress (optional)
echo "🌍 Creating ingress..."
kubectl apply -f "$K8S_DIR/ingress.yaml"
echo "✓ Ingress created"
echo ""

# Wait for all pods to be ready
echo "⏳ Waiting for all deployments to be ready..."
kubectl rollout status deployment/nginx-deployment -n app-namespace
kubectl rollout status deployment/flask-app -n app-namespace
echo ""

echo "✅ Deployment complete!"
echo ""
echo "📊 Deployment status:"
kubectl get all -n app-namespace
echo ""
echo "🎯 Access your application:"
echo ""

# For minikube
if command -v minikube &> /dev/null; then
    echo "Run: minikube service nginx-service -n app-namespace"
    echo "Then open: http://$(minikube ip):30080"
else
    echo "Run: kubectl port-forward svc/nginx-service 8080:80 -n app-namespace"
    echo "Then open: http://localhost:8080"
fi
echo ""

echo "📝 Useful commands:"
echo "  kubectl logs -f deployment/nginx-deployment -n app-namespace"
echo "  kubectl logs -f deployment/flask-app -n app-namespace"
echo "  kubectl logs -f deployment/mysql-deployment -n app-namespace"
echo "  kubectl exec -it deployment/mysql-deployment -n app-namespace -- mysql -u root -p"
