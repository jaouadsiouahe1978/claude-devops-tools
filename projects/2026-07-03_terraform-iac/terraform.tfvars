# Valeurs des variables Terraform
# À customiser selon votre environnement

aws_region   = "eu-west-1"
project_name = "devops-training"
environment  = "dev"

# VPC Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# EC2 Configuration
instance_type = "t3.micro"  # Free tier eligible
ec2_count     = 1           # Number of instances

# RDS Configuration
db_engine        = "postgres"
db_instance_class = "db.t3.micro"  # Free tier eligible
db_name          = "myappdb"
db_username      = "admin"
db_password      = "ChangeMe123!"  # ⚠️ Change this!

# Tags
common_tags = {
  Project     = "devops-training"
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "Jaouad"
  Team        = "DevOps"
}
