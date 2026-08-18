.PHONY: help init plan apply destroy validate fmt show console

help:
	@echo "Terraform Multi-Tier Infrastructure - Available Commands"
	@echo "========================================================="
	@echo "make init      - Initialize Terraform"
	@echo "make plan      - Generate execution plan"
	@echo "make apply     - Apply the infrastructure changes"
	@echo "make destroy   - Destroy the infrastructure"
	@echo "make validate  - Validate Terraform configuration"
	@echo "make fmt       - Format Terraform files"
	@echo "make show      - Show current state"
	@echo "make console   - Launch Terraform console"
	@echo "make console   - Launch interactive Terraform shell"
	@echo ""
	@echo "Environment variables:"
	@echo "  TF_VAR_environment - Set environment (dev/staging/prod)"
	@echo "  TF_VAR_project_name - Set project name"

init:
	terraform init

plan: validate
	terraform plan -out=tfplan

apply:
	terraform apply tfplan

destroy:
	terraform destroy

validate:
	terraform validate

fmt:
	terraform fmt -recursive .

show:
	terraform state list
	@echo ""
	terraform show

console:
	terraform console

refresh:
	terraform refresh

state-pull:
	terraform state pull > terraform.state.backup

state-lock-info:
	terraform state lock info

clean:
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f terraform.tfstate*
	rm -rf config/
	rm -f inventory-*.json

setup-dev:
	TF_VAR_environment=dev make init plan

setup-staging:
	TF_VAR_environment=staging make init plan

setup-prod:
	TF_VAR_environment=prod make init plan

taint:
	@echo "Taint a resource to force recreation:"
	@echo "  terraform taint <resource>"

import:
	@echo "Import an existing resource:"
	@echo "  terraform import <resource> <id>"

workspace-list:
	terraform workspace list

workspace-new:
	@echo "Creating new workspace..."
	terraform workspace new dev

output:
	terraform output -json | jq .

debug:
	TF_LOG=DEBUG terraform plan
