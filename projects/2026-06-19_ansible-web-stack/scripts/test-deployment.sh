#!/bin/bash

# Test deployment status
# Usage: ./scripts/test-deployment.sh

echo "🧪 Testing Deployment Status"
echo "============================="

INVENTORY="${1:-inventory/hosts.ini}"

if [ ! -f "$INVENTORY" ]; then
    echo "❌ Inventory file not found: $INVENTORY"
    exit 1
fi

echo "Testing webservers..."
echo "---"

# Test Nginx on webservers
ansible webservers -i "$INVENTORY" -m shell -a "curl -s http://localhost/health | head -1" -v

echo ""
echo "Testing Node.js on webservers..."
ansible webservers -i "$INVENTORY" -m shell -a "curl -s http://localhost:3000 | jq '.' | head -5" -v

echo ""
echo "Testing PostgreSQL on dbservers..."
ansible dbservers -i "$INVENTORY" -m shell -a "sudo -u postgres psql -c 'SELECT 1'" -v

echo ""
echo "✅ Deployment tests complete!"
