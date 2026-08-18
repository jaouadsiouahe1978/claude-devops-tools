# ============================================
# Network Module
# ============================================

variable "environment" {
  type = string
}

variable "cidr_block" {
  type = string
}

# Network configuration
locals {
  network_config = {
    cidr         = var.cidr_block
    environment  = var.environment
    subnets = [
      {
        name = "public-subnet-1"
        cidr = cidrsubnet(var.cidr_block, 2, 0)
      },
      {
        name = "private-subnet-1"
        cidr = cidrsubnet(var.cidr_block, 2, 1)
      },
      {
        name = "private-subnet-2"
        cidr = cidrsubnet(var.cidr_block, 2, 2)
      }
    ]
  }
}

output "network_info" {
  value = local.network_config
}

output "vpc_cidr" {
  value = var.cidr_block
}
