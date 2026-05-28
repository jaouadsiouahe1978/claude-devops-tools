#!/bin/bash
# Script pour afficher le plan Terraform

set -e

echo "📋 Generating Terraform Plan..."
echo "=================================="

cd "$(dirname "$0")/.."

# Validate first
echo "Validating configuration..."
terraform validate

# Generate plan
echo ""
echo "Generating plan..."
terraform plan -out=tfplan

echo ""
echo "✅ Plan saved to tfplan"
echo "Review the plan above, then run: ./scripts/apply.sh"
