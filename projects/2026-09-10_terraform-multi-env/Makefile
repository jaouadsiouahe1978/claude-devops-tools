.PHONY: help init plan apply destroy validate output

ENVIRONMENT ?= dev
TF_DIR := terraform

help:
	@echo "Terraform Multi-Environment Management"
	@echo "Usage: make [target] ENVIRONMENT=dev|staging|prod"
	@echo ""
	@echo "Targets:"
	@echo "  init     - Initialize Terraform"
	@echo "  validate - Validate configuration"
	@echo "  plan     - Plan changes"
	@echo "  apply    - Apply changes"
	@echo "  destroy  - Destroy infrastructure"
	@echo "  output   - Show outputs"

init:
	cd $(TF_DIR) && terraform init

validate:
	cd $(TF_DIR) && terraform validate

plan:
	cd $(TF_DIR) && terraform plan -var-file=environments/$(ENVIRONMENT)/terraform.tfvars -out=$(ENVIRONMENT).tfplan

apply:
	cd $(TF_DIR) && terraform apply $(ENVIRONMENT).tfplan

destroy:
	cd $(TF_DIR) && terraform destroy -var-file=environments/$(ENVIRONMENT)/terraform.tfvars

output:
	cd $(TF_DIR) && terraform output

.DEFAULT_GOAL := help
