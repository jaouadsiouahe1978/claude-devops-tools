#!/bin/bash
# Setup script - Prepare environment for Terraform deployment

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
  echo -e "${GREEN}[SETUP]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check system
log "Checking system requirements..."

if ! command -v terraform &> /dev/null; then
  warn "Terraform not found. Install from: https://www.terraform.io/downloads"
fi

if ! command -v aws &> /dev/null; then
  warn "AWS CLI not found. Install from: https://aws.amazon.com/cli/"
fi

# Make scripts executable
log "Making scripts executable..."
chmod +x "$(dirname "$0")/deploy.sh"
chmod +x "$(dirname "$0")/destroy.sh"
chmod +x "$(dirname "$0")"/validate.sh 2>/dev/null || true
log "✓ Scripts ready"

# Create directories
log "Creating directories..."
mkdir -p .terraform
mkdir -p terraform.logs
log "✓ Directories created"

# Suggest next steps
echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Configure AWS: aws configure"
echo "  2. Review variables: nano terraform.tfvars"
echo "  3. Deploy: bash scripts/deploy.sh"
echo "  4. Or destroy: bash scripts/destroy.sh"
echo ""
echo "📚 Documentation:"
echo "  - README.md - Full guide"
echo "  - variables.tf - Available variables"
echo "  - outputs.tf - Output values"
echo ""
