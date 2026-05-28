#!/bin/bash
# Script pour détruire l'infrastructure

set -e

echo "⚠️  WARNING: Destroying Terraform Infrastructure"
echo "=============================================="
echo "This will delete all AWS resources created by this Terraform configuration."
echo ""

cd "$(dirname "$0")/.."

read -p "Are you sure you want to destroy? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Destruction cancelled."
    exit 0
fi

echo ""
echo "Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "✅ Infrastructure destroyed successfully!"
