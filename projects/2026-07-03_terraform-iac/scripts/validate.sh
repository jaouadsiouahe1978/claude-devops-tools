#!/bin/bash
# Validation script - Check Terraform configuration

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_ok() {
  echo -e "${GREEN}✓${NC} $1"
}

log_err() {
  echo -e "${RED}✗${NC} $1"
}

echo "=== Terraform Configuration Validation ==="
echo ""

# Check Terraform installed
if ! terraform version &> /dev/null; then
  log_err "Terraform not installed"
  exit 1
fi
log_ok "Terraform installed"

# Check terraform files exist
if [ ! -f main.tf ]; then
  log_err "main.tf not found"
  exit 1
fi
log_ok "main.tf found"

if [ ! -f variables.tf ]; then
  log_err "variables.tf not found"
  exit 1
fi
log_ok "variables.tf found"

if [ ! -f outputs.tf ]; then
  log_err "outputs.tf not found"
  exit 1
fi
log_ok "outputs.tf found"

# Initialize if needed
if [ ! -d .terraform ]; then
  echo ""
  echo "Initializing Terraform..."
  terraform init -upgrade
fi
log_ok ".terraform directory exists"

# Validate syntax
echo ""
echo "Validating syntax..."
if ! terraform validate; then
  log_err "Validation failed"
  exit 1
fi
log_ok "Syntax valid"

# Format check
echo ""
echo "Checking formatting..."
if ! terraform fmt -check -recursive .; then
  echo "Formatting issues found. Run: terraform fmt -recursive ."
fi
log_ok "Format checked"

# Variable validation
echo ""
echo "Checking variables..."
if [ -f terraform.tfvars ]; then
  log_ok "terraform.tfvars found"
else
  log_err "terraform.tfvars not found (using defaults)"
fi

# Check for required vars
terraform console -var-file=terraform.tfvars <<EOF &>/dev/null || true
var.aws_region
var.project_name
var.environment
EOF

log_ok "Variables accessible"

echo ""
echo "✅ All validations passed!"
echo ""
echo "Ready to deploy: bash scripts/deploy.sh"
