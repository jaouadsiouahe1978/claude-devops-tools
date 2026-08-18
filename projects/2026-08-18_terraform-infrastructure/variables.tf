# ============================================
# Variables Declaration
# ============================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myapp"
}

# ============================================
# Network Variables
# ============================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

# ============================================
# Web Server Variables
# ============================================

variable "webserver_name" {
  description = "Name of the web server"
  type        = string
  default     = "webserver-01"
}

variable "webserver_port" {
  description = "Port for web server"
  type        = number
  default     = 8080

  validation {
    condition     = var.webserver_port > 1024 && var.webserver_port < 65535
    error_message = "Port must be between 1024 and 65535."
  }
}

variable "webserver_image" {
  description = "Docker image for web server"
  type        = string
  default     = "nginx:latest"
}

# ============================================
# Database Variables
# ============================================

variable "db_host" {
  description = "Database host"
  type        = string
  default     = "db.internal"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "Database port must be valid."
  }
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "dbuser"
  sensitive   = true
}

# ============================================
# Cache Variables
# ============================================

variable "cache_host" {
  description = "Cache server host"
  type        = string
  default     = "redis.internal"
}

variable "cache_port" {
  description = "Cache server port"
  type        = number
  default     = 6379

  validation {
    condition     = var.cache_port > 0 && var.cache_port < 65536
    error_message = "Cache port must be valid."
  }
}

# ============================================
# Configuration Variables
# ============================================

variable "enable_monitoring" {
  description = "Enable infrastructure monitoring"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    Team       = "DevOps"
    ManagedBy  = "Terraform"
    CostCenter = "Engineering"
  }
}
