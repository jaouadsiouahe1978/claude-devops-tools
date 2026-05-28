#!/bin/bash
# Script pour afficher tous les outputs Terraform

cd "$(dirname "$0")/.."

echo "📊 Terraform Outputs"
echo "===================="
echo ""

terraform output

echo ""
echo "Quick Links:"
echo "============"
NGINX_IP=$(terraform output -raw nginx_instance_ip 2>/dev/null || echo "")
if [ -n "$NGINX_IP" ]; then
    echo "🌐 Nginx: http://$NGINX_IP"
    echo "🔐 SSH: ssh -i /path/to/key.pem ubuntu@$NGINX_IP"
else
    echo "ℹ️  No instances deployed yet. Run: ./scripts/apply.sh"
fi
