#!/bin/bash

set -e

echo "=================================="
echo "Terraform AWS ALB - Destroy"
echo "=================================="
echo ""
echo "⚠️  WARNING: This will DELETE all infrastructure!"
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No terraform.tfstate found. Nothing to destroy."
    exit 1
fi

# Show what will be destroyed
echo "📋 Planning destruction..."
terraform plan -destroy -out=destroy_plan
echo ""

# Ask for confirmation
read -p "This action CANNOT be undone. Type 'destroy' to confirm: " confirm
if [ "$confirm" != "destroy" ]; then
    echo "❌ Destruction cancelled"
    rm -f destroy_plan
    exit 1
fi

# Destroy infrastructure
echo ""
echo "🗑️  Destroying infrastructure..."
terraform apply destroy_plan
rm -f destroy_plan

echo ""
echo "=================================="
echo "✓ Infrastructure destroyed!"
echo "=================================="
echo ""
echo "💡 All AWS resources have been removed."
echo "   Charges should stop accumulating."
echo ""
