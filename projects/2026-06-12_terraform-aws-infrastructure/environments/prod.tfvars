# Environnement PRODUCTION
# Usage: terraform apply -var-file="environments/prod.tfvars" -var="db_password=YOUR_SECURE_PASSWORD"

aws_region         = "eu-west-1"
environment        = "prod"
project_name       = "devops-app-prod"
instance_type      = "t3.medium"
db_instance_class  = "db.t3.medium"
backup_retention_days = 30
enable_public_ip   = false

# ⚠️ IMPORTANT: Passer le mot de passe en ligne de commande ou via variable d'environnement
# Ne JAMAIS commiter les secrets en production !
# TF_VAR_db_password=secure_password terraform apply -var-file="environments/prod.tfvars"
