#!/bin/bash

set -e

PROJECT_NAME="devops-elb"
REGION="eu-west-1"

echo "=================================="
echo "Terraform AWS ALB Deployment"
echo "=================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi

# Verify AWS credentials
echo "🔍 Verifying AWS credentials..."
if ! aws sts get-caller-identity --region $REGION &> /dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi
echo "✓ AWS credentials OK"
echo ""

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init
echo "✓ Terraform initialized"
echo ""

# Format Terraform files
echo "🔧 Formatting Terraform files..."
terraform fmt
echo "✓ Formatted"
echo ""

# Validate Terraform
echo "✔️  Validating Terraform configuration..."
terraform validate
echo "✓ Validation passed"
echo ""

# Plan deployment
echo "📋 Planning infrastructure deployment..."
terraform plan -out=tfplan
echo ""

# Ask for confirmation
read -p "Do you want to proceed with the deployment? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 1
fi

# Apply deployment
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply tfplan
rm -f tfplan
echo ""

# Get outputs
echo "=================================="
echo "✓ Deployment completed!"
echo "=================================="
echo ""
echo "📊 Deployment Information:"
terraform output
echo ""
echo "💡 Next steps:"
echo "1. Wait 2-3 minutes for instances to initialize"
echo "2. Access your application:"
echo "   ALB URL: $(terraform output -raw application_url)"
echo "3. Monitor Auto Scaling in AWS Console"
echo "4. Test scaling: run 'ab -n 10000 -c 100 \$(terraform output -raw application_url)'"
echo "5. When done, cleanup: ./destroy.sh"
echo ""
