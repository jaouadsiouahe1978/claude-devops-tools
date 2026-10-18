#!/bin/bash
# Local testing script for Ansible project

set -e

echo "=========================================="
echo "Ansible Local Testing Script"
echo "=========================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Function to print status
print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Start Docker containers
print_info "Starting Docker containers..."
docker-compose -f docker-compose-test.yml up -d

print_status "Containers started"
echo

# Wait for containers to be ready
print_info "Waiting for containers to be ready..."
sleep 10

# Get container IPs
print_info "Getting container information..."
WEB1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web1)
WEB2_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web2)
DB1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' db1)

echo "Web1 IP: $WEB1_IP"
echo "Web2 IP: $WEB2_IP"
echo "DB1 IP:  $DB1_IP"
echo

# Update inventory file
print_info "Updating inventory file..."
cat > inventory/hosts-docker << EOF
[webservers]
web1 ansible_host=$WEB1_IP ansible_user=root
web2 ansible_host=$WEB2_IP ansible_user=root

[databases]
db1 ansible_host=$DB1_IP ansible_user=root

[all:vars]
ansible_user = root
ansible_ssh_common_args = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter = /usr/bin/python3
EOF

print_status "Inventory updated"
echo

# Test connectivity
print_info "Testing Ansible connectivity..."
ansible -i inventory/hosts-docker all -m ping

echo
print_status "All containers are reachable"
echo

# Run playbooks
print_info "Running full configuration playbook..."
ansible-playbook site.yml -i inventory/hosts-docker -v --extra-vars "update_packages=no"

echo
print_status "Playbook execution complete"
echo

# Run tests
print_info "Running validation tests..."
ansible-playbook test-playbook.yml -i inventory/hosts-docker -v

echo
print_status "All tests passed!"
echo

# Cleanup option
read -p "Do you want to stop the Docker containers? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Stopping containers..."
    docker-compose -f docker-compose-test.yml down
    print_status "Containers stopped"
else
    print_info "Containers still running. Use 'docker-compose -f docker-compose-test.yml down' to stop them."
fi

echo
echo "=========================================="
echo "Testing Complete"
echo "=========================================="
