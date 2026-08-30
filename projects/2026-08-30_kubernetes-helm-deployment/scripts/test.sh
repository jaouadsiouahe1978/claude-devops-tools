#!/bin/bash
set -euo pipefail

ENV="${1:-dev}"
RELEASE_NAME="myapp-${ENV}"
NAMESPACE="${ENV}"

echo "🧪 Testing deployment in $NAMESPACE..."

# Wait for pods to be ready
kubectl wait --for=condition=ready pod \
    -l "app=${RELEASE_NAME}" \
    -n "$NAMESPACE" \
    --timeout=300s || echo "Timeout waiting for pods"

# Port-forward and test
kubectl port-forward -n "$NAMESPACE" "svc/${RELEASE_NAME}" 5000:5000 >/dev/null 2>&1 &
PF_PID=$!
sleep 2

echo "Testing /health endpoint..."
if curl -s http://localhost:5000/health | grep -q "healthy"; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed!"
    kill $PF_PID
    exit 1
fi

echo "Testing / endpoint..."
if curl -s http://localhost:5000/ | grep -q "Hello"; then
    echo "✅ Home endpoint OK!"
fi

kill $PF_PID
echo "✅ All tests passed!"
