#!/bin/bash
# Deploy script - Automated Terraform deployment

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Check prerequisites
check_prerequisites() {
  log_info "Checking prerequisites..."

  # Check Terraform
  if ! command -v terraform &> /dev/null; then
    log_error "Terraform is not installed"
  fi
  log_info "✓ Terraform found: $(terraform version | head -1)"

  # Check AWS CLI
  if ! command -v aws &> /dev/null; then
    log_error "AWS CLI is not installed"
  fi
  log_info "✓ AWS CLI found: $(aws --version)"

  # Check AWS credentials
  if ! aws sts get-caller-identity &> /dev/null; then
    log_error "AWS credentials not configured or invalid"
  fi
  log_info "✓ AWS credentials valid"
}

# Initialize Terraform
init_terraform() {
  log_info "Initializing Terraform..."
  terraform init
  log_info "✓ Terraform initialized"
}

# Validate configuration
validate_config() {
  log_info "Validating Terraform configuration..."
  terraform validate
  log_info "✓ Configuration valid"
}

# Plan deployment
plan_deployment() {
  log_info "Planning deployment..."
  terraform plan -out=tfplan
  log_info "✓ Plan created (tfplan)"
}

# Show plan details
show_plan() {
  log_info "Plan summary:"
  terraform show tfplan | grep -E "will be|must be" | head -20
  echo ""
  log_warn "Review the plan above. Proceed? (yes/no)"
  read -r response
  if [ "$response" != "yes" ]; then
    log_warn "Deployment cancelled"
    rm -f tfplan
    exit 0
  fi
}

# Apply deployment
apply_deployment() {
  log_info "Applying deployment..."
  terraform apply tfplan
  rm -f tfplan
  log_info "✓ Deployment complete"
}

# Show outputs
show_outputs() {
  log_info "Deployment outputs:"
  echo ""
  terraform output
  echo ""
}

# Save outputs to file
save_outputs() {
  local output_file="deployment-outputs-$(date +%s).json"
  log_info "Saving outputs to $output_file..."
  terraform output -json > "$output_file"
  log_info "✓ Outputs saved"
}

# Main workflow
main() {
  log_info "=== Terraform Deployment Script ==="
  echo ""

  check_prerequisites
  echo ""

  init_terraform
  echo ""

  validate_config
  echo ""

  plan_deployment
  echo ""

  show_plan
  echo ""

  apply_deployment
  echo ""

  show_outputs
  echo ""

  save_outputs
  echo ""

  log_info "=== Deployment Complete ==="
  log_info "Next steps:"
  echo "  1. Test connectivity: aws ec2 describe-instances"
  echo "  2. SSH to instance: ssh -i <key.pem> ec2-user@<public-ip>"
  echo "  3. Test database: psql -h <rds-endpoint> -U admin -d myappdb"
}

# Run main
main "$@"
