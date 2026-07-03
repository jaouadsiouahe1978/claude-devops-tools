#!/bin/bash
# Destroy script - Remove Terraform infrastructure

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Confirm destruction
confirm_destruction() {
  log_warn "⚠️  WARNING: This will destroy ALL infrastructure!"
  echo ""
  log_warn "Resources to be destroyed:"
  terraform plan -destroy | grep "will be destroyed" | head -10
  echo ""
  log_error "Type 'destroy-all' to confirm (all lowercase):"
  read -r confirmation
  if [ "$confirmation" != "destroy-all" ]; then
    log_info "Destruction cancelled"
    exit 0
  fi
}

# Show what will be destroyed
show_destroy_plan() {
  log_info "Planning destruction..."
  terraform plan -destroy -out=destroy.plan
}

# Destroy infrastructure
destroy_infrastructure() {
  log_warn "Destroying infrastructure..."
  terraform apply destroy.plan
  rm -f destroy.plan
  log_info "✓ Infrastructure destroyed"
}

# Clean up local files
cleanup_local() {
  log_info "Cleaning up local files..."
  rm -f terraform.tfstate
  rm -f terraform.tfstate.backup
  rm -f .terraform.lock.hcl
  rm -rf .terraform/
  log_info "✓ Local files cleaned"
}

# Main
main() {
  log_warn "=== Infrastructure Destruction ==="
  echo ""

  confirm_destruction
  echo ""

  show_destroy_plan
  echo ""

  log_warn "Proceeding with destruction? (yes/no)"
  read -r final_confirm
  if [ "$final_confirm" != "yes" ]; then
    log_info "Destruction cancelled"
    rm -f destroy.plan
    exit 0
  fi
  echo ""

  destroy_infrastructure
  echo ""

  log_warn "Clean local state? (yes/no)"
  read -r clean_confirm
  if [ "$clean_confirm" == "yes" ]; then
    cleanup_local
  fi
  echo ""

  log_info "=== Destruction Complete ==="
}

main "$@"
