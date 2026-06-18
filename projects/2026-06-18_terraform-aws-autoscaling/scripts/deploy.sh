#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")/terraform"

echo "🚀 Deploying Terraform Infrastructure"
echo "====================================="

command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform not found"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI not found"; exit 1; }

echo "🔑 Verifying AWS credentials..."
aws sts get-caller-identity > /dev/null 2>&1 || { echo "❌ AWS credentials not configured"; exit 1; }

cd "$TF_DIR"
echo "🔧 Initializing Terraform..."
terraform init

echo "✓ Validating configuration..."
terraform validate

echo ""
echo "📊 Terraform Plan:"
terraform plan -out=tfplan

read -p "Apply changes? (yes/no): " -r CONFIRM
[[ $CONFIRM =~ ^[Yy][Ee][Ss]$ ]] || { rm tfplan; exit 0; }

echo "⏳ Applying..."
terraform apply tfplan
rm tfplan

echo "✅ Deployment complete!"
echo ""
echo "Outputs:"
terraform output
