#!/bin/bash
set -e

NAMESPACE="devops-app"

echo "🧪 Running integration tests..."
echo ""

# Function to check pod status
check_pod_status() {
    local component=$1
    local label=$2

    echo -n "  ✓ Checking $component status..."
    local ready=$(kubectl get pods -n $NAMESPACE -l $label -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")

    if [ "$ready" == "True" ]; then
        echo " OK"
        return 0
    else
        echo " PENDING"
        return 1
    fi
}

# Function to check service
check_service() {
    local service=$1

    echo -n "  ✓ Checking service $service..."
    if kubectl get svc $service -n $NAMESPACE &>/dev/null; then
        echo " OK"
        return 0
    else
        echo " MISSING"
        return 1
    fi
}

echo "1️⃣  Checking Namespace"
if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo "  ✓ Namespace exists"
else
    echo "  ✗ Namespace does not exist"
    exit 1
fi

echo ""
echo "2️⃣  Checking Pods"
check_pod_status "API" "app.kubernetes.io/component=api"
check_pod_status "PostgreSQL" "app.kubernetes.io/component=database"
check_pod_status "Redis" "app.kubernetes.io/component=cache"

echo ""
echo "3️⃣  Checking Services"
check_service "api-service"
check_service "postgres-service"
check_service "redis-service"

echo ""
echo "4️⃣  Checking ConfigMaps"
echo -n "  ✓ Checking ConfigMap..."
if kubectl get configmap -n $NAMESPACE -l app.kubernetes.io/name=devops-app &>/dev/null; then
    echo " OK"
else
    echo " MISSING"
fi

echo ""
echo "5️⃣  Checking Secrets"
echo -n "  ✓ Checking postgres-secret..."
if kubectl get secret postgres-secret -n $NAMESPACE &>/dev/null; then
    echo " OK"
else
    echo " MISSING"
fi

echo ""
echo "6️⃣  Checking PersistentVolumeClaims"
echo -n "  ✓ Checking postgres-pvc..."
if kubectl get pvc -n $NAMESPACE -l app.kubernetes.io/component=database &>/dev/null; then
    echo " OK"
else
    echo " MISSING"
fi

echo ""
echo "7️⃣  Checking Resource Limits"
echo "  API Deployment:"
kubectl get deployment -n $NAMESPACE -l app.kubernetes.io/component=api -o jsonpath='{.items[0].spec.template.spec.containers[0].resources}'
echo ""

echo ""
echo "✨ Test summary"
echo ""
echo "📊 All resources:"
kubectl get all -n $NAMESPACE

echo ""
echo "💡 Next steps:"
echo "  1. Port-forward to API: kubectl port-forward svc/api-service 8080:80 -n $NAMESPACE"
echo "  2. Test health: curl http://localhost:8080/health"
echo "  3. Check logs: kubectl logs -f deploy/devops-app-api -n $NAMESPACE"
