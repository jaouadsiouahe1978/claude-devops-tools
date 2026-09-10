# 🚀 Quick Start

## 1. Initialize
```bash
make init ENVIRONMENT=dev
# Or: cd terraform && terraform init
```

## 2. Plan
```bash
make plan ENVIRONMENT=dev
# Or: cd terraform && terraform plan -var-file=environments/dev/terraform.tfvars -out=dev.tfplan
```

## 3. Apply
```bash
make apply ENVIRONMENT=dev
# Or: cd terraform && terraform apply dev.tfplan
```

## 4. View Outputs
```bash
make output ENVIRONMENT=dev
# Or: cd terraform && terraform output
```

## 5. Destroy
```bash
make destroy ENVIRONMENT=dev
# Or: cd terraform && terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Multi-Environment Workflow

```bash
# Dev
make plan ENVIRONMENT=dev
make apply ENVIRONMENT=dev

# Staging
make plan ENVIRONMENT=staging
make apply ENVIRONMENT=staging

# Production
make plan ENVIRONMENT=prod
make apply ENVIRONMENT=prod
```

## Key Concepts

- **Modules**: VPC, Security, Compute (reusable components)
- **Environments**: dev (1 instance), staging (2), prod (3)
- **Variables**: Defined in variables.tf
- **Outputs**: Defined in outputs.tf
- **State**: Stored in terraform.tfstate (local for demo)

## Learning Path

1. ✅ Initialize Terraform
2. ✅ Understand variables and outputs
3. ✅ Plan and apply dev environment
4. ✅ Review created resources in AWS
5. ✅ Scale to staging/prod
6. ✅ Learn state management
7. ✅ Setup remote backend (S3 + DynamoDB)
