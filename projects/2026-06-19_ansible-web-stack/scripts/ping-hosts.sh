#!/bin/bash

# Test connectivity to all hosts
# Usage: ./scripts/ping-hosts.sh

echo "🔍 Testing connectivity to all hosts..."
echo "========================================"

# Use inventory from current directory
INVENTORY="${1:-inventory/hosts.ini}"

if [ ! -f "$INVENTORY" ]; then
    echo "❌ Inventory file not found: $INVENTORY"
    exit 1
fi

echo "Using inventory: $INVENTORY"
echo ""

# Ping all hosts
ansible all -i "$INVENTORY" -m ping -v

echo ""
echo "✅ Connectivity test complete!"
