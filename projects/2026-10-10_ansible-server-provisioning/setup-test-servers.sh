#!/bin/bash

##
# Setup Test Servers for Ansible Testing
# This script prepares Docker containers to be used with Ansible
##

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🚀 Setting up Ansible test environment..."
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found. Please install Docker and docker-compose."
    exit 1
fi

# Start test servers
echo "📦 Starting test containers..."
docker-compose -f docker-compose-test.yml up -d

echo "⏳ Waiting for containers to start..."
sleep 5

# Get container IPs
UBUNTU_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible-test-ubuntu)
CENTOS_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible-test-centos)

echo "✅ Containers started:"
echo "   Ubuntu server: $UBUNTU_IP (port 2222)"
echo "   CentOS server: $CENTOS_IP (port 2223)"
echo ""

# Setup SSH in Ubuntu container
echo "🔐 Setting up SSH in Ubuntu container..."
docker exec ansible-test-ubuntu bash -c '
    apt-get update -qq
    apt-get install -y openssh-server openssh-client python3
    mkdir -p /run/sshd
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
    sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
    service ssh start
'

echo "✅ SSH configured in Ubuntu container"
echo ""

# Generate SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

echo ""
echo "📝 Update your inventory.ini with:"
echo ""
echo "[webservers]"
echo "$UBUNTU_IP ansible_user=root ansible_port=22"
echo ""
echo "[dbservers]"
echo "$CENTOS_IP ansible_user=root ansible_port=22"
echo ""
echo ""
echo "🧪 Test Ansible connectivity:"
echo "ansible all -i inventory.ini -m ping"
echo ""
echo "📚 To clean up test containers:"
echo "docker-compose -f docker-compose-test.yml down"
