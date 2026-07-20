#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check prerequisites
print_header "Checking Prerequisites"

if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    exit 1
fi
print_success "Terraform is installed ($(terraform version | head -1))"

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed"
    exit 1
fi
print_success "AWS CLI is installed"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials are not configured"
    exit 1
fi
print_success "AWS credentials configured"

# Initialize Terraform
print_header "Initializing Terraform"
terraform init
print_success "Terraform initialized"

# Validate configuration
print_header "Validating Configuration"
terraform validate
print_success "Configuration is valid"

# Check for terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found"
    print_warning "Copying from terraform.tfvars.example"
    cp terraform.tfvars.example terraform.tfvars
    print_warning "Please edit terraform.tfvars with your values before deploying"
    exit 0
fi

# Plan
print_header "Planning Deployment"
terraform plan -out=tfplan
print_success "Plan created (tfplan)"

# Ask for confirmation
print_warning "Review the plan above. Do you want to apply? (yes/no)"
read -r response

if [ "$response" != "yes" ]; then
    print_error "Deployment cancelled"
    exit 1
fi

# Apply
print_header "Applying Configuration"
terraform apply tfplan
print_success "Infrastructure deployed successfully"

# Show outputs
print_header "Deployment Outputs"
terraform output

print_success "Deployment completed!"
print_warning "Remember to run 'terraform destroy' when done to avoid AWS costs"
