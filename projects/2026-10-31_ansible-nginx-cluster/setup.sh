#!/bin/bash

# Setup script for Ansible Nginx Cluster project

set -e

echo "================================================"
echo "🚀 Ansible Nginx Cluster - Setup Script"
echo "================================================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! command -v ansible &> /dev/null; then
    echo "⚠️  Ansible is not installed. Install with: pip install ansible"
    echo "   Attempting to install..."
    pip install ansible || {
        echo "❌ Failed to install Ansible"
        exit 1
    }
fi

echo "✅ All prerequisites are met"
echo ""

# Start Docker containers
echo "🐳 Starting Docker containers..."
docker-compose up -d

# Wait for containers to be ready
echo "⏳ Waiting for SSH to be ready..."
sleep 5

# Test connectivity
echo "🔗 Testing Ansible connectivity..."
for i in {1..5}; do
    if ansible all -i inventory.ini -m ping > /dev/null 2>&1; then
        echo "✅ All hosts are reachable"
        break
    fi
    echo "  Attempt $i/5... retrying"
    sleep 2
done

echo ""
echo "================================================"
echo "✅ Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Deploy Nginx: ansible-playbook -i inventory.ini playbook.yml"
echo "  2. Test servers:"
echo "     - curl http://localhost:8001"
echo "     - curl http://localhost:8002"
echo "     - curl http://localhost:8003"
echo ""
echo "To clean up:"
echo "  docker-compose down"
echo ""
