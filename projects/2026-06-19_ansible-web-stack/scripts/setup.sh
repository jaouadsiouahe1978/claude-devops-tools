#!/bin/bash

# Setup script for Ansible DevOps Stack
# Usage: ./scripts/setup.sh

set -e

echo "🚀 DevOps Stack - Ansible Setup Script"
echo "========================================"

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible not found. Installing..."
    sudo apt update
    sudo apt install -y ansible
else
    echo "✅ Ansible found: $(ansible --version | head -1)"
fi

# Generate SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
else
    echo "✅ SSH key already exists"
fi

# Check inventory
if [ ! -f inventory/hosts.ini ]; then
    echo "❌ inventory/hosts.ini not found"
    exit 1
fi

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update inventory/hosts.ini with your server IPs"
echo "2. Copy SSH key to servers: ssh-copy-id -i ~/.ssh/id_rsa.pub user@server"
echo "3. Test connectivity: ansible all -i inventory/hosts.ini -m ping"
echo "4. Deploy: ansible-playbook -i inventory/hosts.ini playbooks/site.yml"
