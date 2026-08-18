# ============================================
# Web Server Module
# ============================================

variable "environment" {
  type = string
}

variable "server_name" {
  type = string
}

variable "port" {
  type = number
}

variable "docker_image" {
  type = string
}

# Web server configuration
locals {
  webserver_config = {
    name        = var.server_name
    environment = var.environment
    port        = var.port
    image       = var.docker_image
    status      = "configured"
    features = [
      "HTTP/2",
      "SSL/TLS",
      "Load Balancing",
      "Compression"
    ]
  }
}

output "status" {
  value = local.webserver_config
}

output "server_name" {
  value = var.server_name
}

output "server_port" {
  value = var.port
}
