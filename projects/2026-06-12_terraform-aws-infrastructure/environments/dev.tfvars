# Environnement DEV
# Usage: terraform apply -var-file="environments/dev.tfvars"

aws_region         = "eu-west-1"
environment        = "dev"
project_name       = "devops-app-dev"
instance_type      = "t3.micro"
db_instance_class  = "db.t3.micro"
backup_retention_days = 1
enable_public_ip   = true
