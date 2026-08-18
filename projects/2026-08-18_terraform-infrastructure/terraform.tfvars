# ============================================
# Terraform Variables - Default Values (Dev)
# ============================================

environment      = "dev"
project_name     = "devops-app"
vpc_cidr         = "10.0.0.0/16"

# Web Server Configuration
webserver_name   = "webserver-dev"
webserver_port   = 8080
webserver_image  = "nginx:alpine"

# Database Configuration
db_host          = "postgres-dev.internal"
db_port          = 5432
db_name          = "appdb_dev"
db_user          = "devuser"

# Cache Configuration
cache_host       = "redis-dev.internal"
cache_port       = 6379

# Features
enable_monitoring = true

# Additional Tags
tags = {
  Team       = "DevOps"
  ManagedBy  = "Terraform"
  CostCenter = "Engineering"
  Version    = "1.0"
}
