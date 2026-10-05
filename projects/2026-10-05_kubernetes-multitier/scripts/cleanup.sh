#!/bin/bash
set -e

echo "🧹 Cleaning up Kubernetes deployment..."
echo ""

# Delete the namespace (this will delete all resources in it)
echo "Deleting namespace app-namespace..."
kubectl delete namespace app-namespace --ignore-not-found=true
echo "✓ Namespace deleted"
echo ""

# Remove Docker images (optional)
read -p "Do you want to remove Docker images? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing Docker images..."
    docker rmi nginx-frontend:latest || true
    docker rmi flask-api:latest || true
    echo "✓ Docker images removed"
fi

echo ""
echo "✅ Cleanup complete!"
