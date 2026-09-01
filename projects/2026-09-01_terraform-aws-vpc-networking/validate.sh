#!/bin/bash

# Validation script for Terraform AWS VPC configuration
# This script validates the Terraform configuration before applying

set -e

echo "=========================================="
echo "Terraform Configuration Validator"
echo "=========================================="
echo ""

# Check if terraform is installed
echo "[1/5] Checking Terraform installation..."
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi
echo "✅ Terraform version: $(terraform version -json | jq -r '.terraform_version')"
echo ""

# Validate terraform files
echo "[2/5] Validating Terraform files..."
if terraform validate > /dev/null 2>&1; then
    echo "✅ Terraform files are valid"
else
    echo "❌ Terraform files have errors"
    terraform validate
    exit 1
fi
echo ""

# Format check
echo "[3/5] Checking Terraform formatting..."
if terraform fmt -check -recursive . > /dev/null 2>&1; then
    echo "✅ Terraform files are properly formatted"
else
    echo "⚠️  Terraform files need formatting. Running terraform fmt..."
    terraform fmt -recursive .
    echo "✅ Files formatted"
fi
echo ""

# Check AWS credentials
echo "[4/5] Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
    REGION=$(aws configure get region)
    echo "✅ AWS credentials valid"
    echo "   Account: $ACCOUNT"
    echo "   Region: ${REGION:-default}"
else
    echo "❌ AWS credentials not configured or invalid"
    echo "   Please configure AWS CLI: aws configure"
    exit 1
fi
echo ""

# Plan validation
echo "[5/5] Planning deployment (no actual changes)..."
if terraform plan -out=/tmp/tfplan > /dev/null 2>&1; then
    echo "✅ Terraform plan successful"
    echo ""
    echo "Plan summary:"
    terraform show -json /tmp/tfplan | jq -r '.resource_changes[] | select(.type != "data") | "\(.change.actions[0] | ascii_upcase): \(.type).\(.name)"'
else
    echo "❌ Terraform plan failed"
    terraform plan
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ All validations passed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the plan: terraform show /tmp/tfplan"
echo "2. Apply changes: terraform apply /tmp/tfplan"
echo "3. Verify resources: terraform output"
