#!/bin/bash
# Script pour appliquer les changements Terraform

set -e

echo "🔧 Applying Terraform Configuration..."
echo "=================================="

cd "$(dirname "$0")/.."

if [ -f tfplan ]; then
    echo "Using existing plan file..."
    terraform apply tfplan
else
    echo "Creating and applying plan..."
    terraform apply -auto-approve
fi

echo ""
echo "✅ Infrastructure deployed successfully!"
echo ""
echo "Outputs:"
terraform output

echo ""
echo "Test Nginx:"
NGINX_IP=$(terraform output -raw nginx_instance_ip 2>/dev/null || echo "")
if [ -n "$NGINX_IP" ]; then
    echo "curl http://$NGINX_IP"
    echo ""
    echo "Wait 60 seconds for the instance to be fully ready..."
fi
