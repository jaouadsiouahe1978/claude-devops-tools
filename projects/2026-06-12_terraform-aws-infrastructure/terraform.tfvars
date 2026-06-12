# Configuration par défaut pour DEV
# À surcharger avec: terraform apply -var-file="environments/prod.tfvars"

aws_region     = "eu-west-1"
environment    = "dev"
project_name   = "devops-app"
vpc_cidr       = "10.0.0.0/16"
instance_type  = "t3.micro"
db_instance_class = "db.t3.micro"
db_name        = "appdb"
db_username    = "dbadmin"

# ⚠️ À générer avec: openssl rand -base64 32
# ⚠️ Ne JAMAIS commiter les vrais secrets !
db_password    = "changeme123!"

enable_public_ip       = true
backup_retention_days  = 7

tags = {
  Owner      = "devops-team"
  Version    = "1.0"
  Terraform  = "true"
}
