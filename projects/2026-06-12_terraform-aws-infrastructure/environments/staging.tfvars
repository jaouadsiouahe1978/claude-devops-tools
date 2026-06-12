# Environnement STAGING
# Usage: terraform apply -var-file="environments/staging.tfvars"

aws_region         = "eu-west-1"
environment        = "staging"
project_name       = "devops-app-staging"
instance_type      = "t3.small"
db_instance_class  = "db.t3.small"
backup_retention_days = 7
enable_public_ip   = false
