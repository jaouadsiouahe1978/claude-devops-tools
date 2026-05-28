#!/bin/bash
# Script pour initialiser Terraform

set -e

echo "🚀 Initializing Terraform..."
echo "=================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ Error: AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

# Initialize Terraform
cd "$(dirname "$0")/.."
terraform init

echo "✅ Terraform initialized successfully!"
echo "Next: terraform plan"
