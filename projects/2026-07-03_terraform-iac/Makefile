.PHONY: help init validate plan apply destroy clean setup fmt

help:
	@echo "DevOps Terraform Infrastructure Management"
	@echo ""
	@echo "Available targets:"
	@echo "  setup       - Initial setup and prerequisites check"
	@echo "  init        - Initialize Terraform"
	@echo "  validate    - Validate Terraform configuration"
	@echo "  plan        - Plan infrastructure changes"
	@echo "  apply       - Apply Terraform configuration"
	@echo "  destroy     - Destroy infrastructure"
	@echo "  fmt         - Format Terraform files"
	@echo "  clean       - Clean Terraform state and cache"
	@echo "  status      - Show current infrastructure status"
	@echo "  output      - Show Terraform outputs"
	@echo "  logs        - Show Terraform logs"
	@echo ""

setup:
	@echo "Running setup..."
	@bash scripts/setup.sh

init:
	@echo "Initializing Terraform..."
	@terraform init -upgrade

validate:
	@echo "Validating configuration..."
	@bash scripts/validate.sh

plan:
	@echo "Planning deployment..."
	@terraform plan -out=tfplan

apply:
	@echo "Applying configuration..."
	@if [ -f tfplan ]; then \
		terraform apply tfplan; \
		rm -f tfplan; \
	else \
		terraform apply; \
	fi

destroy:
	@echo "Destroying infrastructure..."
	@bash scripts/destroy.sh

clean:
	@echo "Cleaning Terraform state..."
	@rm -rf .terraform
	@rm -f terraform.tfstate*
	@rm -f .terraform.lock.hcl
	@rm -f tfplan
	@rm -f destroy.plan

fmt:
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive .

status:
	@echo "Infrastructure status:"
	@terraform show | head -50

output:
	@echo "Terraform outputs:"
	@terraform output

logs:
	@ls -lah terraform.logs/ 2>/dev/null || echo "No logs yet"

# Advanced targets
console:
	@terraform console

debug:
	@TF_LOG=DEBUG terraform plan 2>&1 | head -100

import:
	@echo "Import existing resource:"
	@echo "Usage: make import RESOURCE=aws_vpc.main ID=vpc-xxxxx"
	@terraform import $(RESOURCE) $(ID)

state-list:
	@terraform state list

state-show:
	@echo "Usage: make state-show RESOURCE=aws_vpc.main"
	@terraform state show $(RESOURCE)

refresh:
	@echo "Refreshing state..."
	@terraform refresh

graph:
	@echo "Generating infrastructure graph..."
	@terraform graph | dot -Tsvg > graph.svg
	@echo "Graph saved to graph.svg"

.DEFAULT_GOAL := help
