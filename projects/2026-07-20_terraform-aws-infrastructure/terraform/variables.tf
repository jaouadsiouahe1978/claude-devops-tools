variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name (used for tagging and naming resources)"
  type        = string
  default     = "myapp"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "database_name" {
  description = "RDS database name"
  type        = string
  default     = "myapp_db"
}

variable "database_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "database_password" {
  description = "RDS master password (change in terraform.tfvars)"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
