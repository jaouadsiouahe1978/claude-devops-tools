.PHONY: help init validate plan apply destroy fmt clean refresh state

ENVIRONMENT ?= dev
TF_VARS = -var-file="environments/$(ENVIRONMENT).tfvars"

help:
	@echo "DevOps Training - Terraform AWS Infrastructure"
	@echo ""
	@echo "Available targets:"
	@echo "  make init          - Initialize Terraform workspace"
	@echo "  make validate      - Validate Terraform configuration"
	@echo "  make fmt           - Format all .tf files"
	@echo "  make plan          - Plan Terraform changes (ENVIRONMENT=dev|staging|prod)"
	@echo "  make apply         - Apply Terraform changes (ENVIRONMENT=dev|staging|prod)"
	@echo "  make destroy       - Destroy infrastructure (ENVIRONMENT=dev|staging|prod)"
	@echo "  make refresh       - Refresh Terraform state"
	@echo "  make state         - Show current state"
	@echo "  make output        - Show outputs"
	@echo "  make clean         - Remove .terraform and lock files"
	@echo ""
	@echo "Example:"
	@echo "  make plan ENVIRONMENT=prod"
	@echo "  make apply ENVIRONMENT=staging"

init:
	@echo "Initializing Terraform..."
	terraform init

validate:
	@echo "Validating Terraform configuration..."
	terraform validate
	terraform fmt -check -recursive

fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

plan:
	@echo "Planning infrastructure for $(ENVIRONMENT)..."
	terraform plan $(TF_VARS) -out=tfplan

apply:
	@echo "Applying infrastructure changes for $(ENVIRONMENT)..."
	terraform apply $(TF_VARS)

destroy:
	@echo "⚠️  WARNING: Destroying infrastructure for $(ENVIRONMENT)!"
	@read -p "Are you sure? (yes/no): " confirm && \
	[ "$$confirm" = "yes" ] && \
	terraform destroy $(TF_VARS) -auto-approve || echo "Cancelled"

refresh:
	@echo "Refreshing Terraform state..."
	terraform refresh $(TF_VARS)

state:
	@echo "Current Terraform state for $(ENVIRONMENT):"
	terraform state list

output:
	@echo "Terraform outputs:"
	terraform output -json

clean:
	@echo "Cleaning Terraform files..."
	rm -rf .terraform .terraform.lock.hcl tfplan tfplan.out

.PHONY: validate-all plan-all
validate-all:
	@for env in dev staging prod; do \
		echo "\n=== Validating $$env ==="; \
		terraform validate -var-file="environments/$$env.tfvars"; \
	done

plan-all:
	@for env in dev staging prod; do \
		echo "\n=== Planning $$env ==="; \
		terraform plan -var-file="environments/$$env.tfvars" -out=tfplan-$$env; \
	done
