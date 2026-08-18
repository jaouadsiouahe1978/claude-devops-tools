# ============================================
# Terraform Configuration - Multi-Tier App
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# ============================================
# Providers
# ============================================

provider "local" {}

# ============================================
# Local Resources (Simulation)
# ============================================

# Création des répertoires pour chaque tier
resource "local_file" "webserver_config" {
  content  = templatefile("${path.module}/templates/webserver.conf.tpl", {
    server_name = var.webserver_name
    port        = var.webserver_port
    environment = var.environment
  })
  filename = "${path.module}/config/webserver-${var.environment}.conf"

  depends_on = [local_dir.config_dir]
}

resource "local_file" "database_config" {
  content  = templatefile("${path.module}/templates/database.conf.tpl", {
    db_host     = var.db_host
    db_port     = var.db_port
    db_name     = var.db_name
    environment = var.environment
  })
  filename = "${path.module}/config/database-${var.environment}.conf"

  depends_on = [local_dir.config_dir]
}

resource "local_file" "cache_config" {
  content  = templatefile("${path.module}/templates/cache.conf.tpl", {
    cache_host = var.cache_host
    cache_port = var.cache_port
    environment = var.environment
  })
  filename = "${path.module}/config/cache-${var.environment}.conf"

  depends_on = [local_dir.config_dir]
}

# Créer le répertoire de config
resource "local_dir" "config_dir" {
  path = "${path.module}/config"
}

# Créer un fichier d'inventaire
resource "local_file" "infrastructure_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    webserver_name = var.webserver_name
    webserver_port = var.webserver_port
    db_host        = var.db_host
    db_port        = var.db_port
    cache_host     = var.cache_host
    cache_port     = var.cache_port
    environment    = var.environment
    created_at     = timestamp()
  })
  filename = "${path.module}/inventory-${var.environment}.json"
}

# ============================================
# Modules
# ============================================

module "network" {
  source = "./modules/network"

  environment = var.environment
  cidr_block  = var.vpc_cidr
}

module "webserver" {
  source = "./modules/webserver"

  environment     = var.environment
  server_name     = var.webserver_name
  port            = var.webserver_port
  docker_image    = var.webserver_image
}

module "database" {
  source = "./modules/database"

  environment = var.environment
  db_host     = var.db_host
  db_port     = var.db_port
  db_name     = var.db_name
  db_user     = var.db_user
}

# ============================================
# Local Variables
# ============================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = "DevOps-Training"
    CreatedBy   = "Terraform"
    CreatedDate = timestamp()
  }

  infrastructure_name = "${var.project_name}-${var.environment}"
}
