# ============================================
# Database Module
# ============================================

variable "environment" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}

# Database configuration
locals {
  database_config = {
    host         = var.db_host
    port         = var.db_port
    database     = var.db_name
    environment  = var.environment
    status       = "configured"
    capabilities = [
      "Replication",
      "Backup",
      "Point-in-time Recovery",
      "Encryption at Rest"
    ]
  }
}

output "status" {
  value = local.database_config
}

output "connection_host" {
  value = var.db_host
}

output "connection_port" {
  value = var.db_port
}

output "database_name" {
  value = var.db_name
}
