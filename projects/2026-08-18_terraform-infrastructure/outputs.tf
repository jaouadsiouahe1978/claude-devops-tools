# ============================================
# Outputs
# ============================================

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "infrastructure_name" {
  description = "Full infrastructure name"
  value       = local.infrastructure_name
}

# ============================================
# Web Server Outputs
# ============================================

output "webserver_config_file" {
  description = "Path to web server configuration file"
  value       = local_file.webserver_config.filename
}

output "webserver_access_url" {
  description = "Web server access URL"
  value       = "http://${var.webserver_name}:${var.webserver_port}"
}

# ============================================
# Database Outputs
# ============================================

output "database_config_file" {
  description = "Path to database configuration file"
  value       = local_file.database_config.filename
}

output "database_connection_string" {
  description = "Database connection string"
  value       = "postgresql://${var.db_user}@${var.db_host}:${var.db_port}/${var.db_name}"
  sensitive   = true
}

# ============================================
# Cache Outputs
# ============================================

output "cache_config_file" {
  description = "Path to cache configuration file"
  value       = local_file.cache_config.filename
}

output "cache_connection_info" {
  description = "Cache server connection info"
  value       = "${var.cache_host}:${var.cache_port}"
}

# ============================================
# Inventory Outputs
# ============================================

output "inventory_file" {
  description = "Path to infrastructure inventory file"
  value       = local_file.infrastructure_inventory.filename
}

# ============================================
# Module Outputs
# ============================================

output "network_config" {
  description = "Network module configuration"
  value       = module.network.network_info
}

output "webserver_status" {
  description = "Web server module status"
  value       = module.webserver.status
}

output "database_status" {
  description = "Database module status"
  value       = module.database.status
}

# ============================================
# Summary Outputs
# ============================================

output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    environment      = var.environment
    name             = local.infrastructure_name
    webserver_url    = "http://${var.webserver_name}:${var.webserver_port}"
    database_host    = var.db_host
    database_port    = var.db_port
    cache_host       = var.cache_host
    cache_port       = var.cache_port
    config_directory = "${path.module}/config"
  }
}

# ============================================
# Common Tags
# ============================================

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}
