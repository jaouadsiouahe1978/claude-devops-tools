terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform   = "true"
      Project     = var.project_name
      Environment = var.environment
      CreatedAt   = timestamp()
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  availability_zones = var.availability_zones
  enable_nat         = var.enable_nat
}

module "security_groups" {
  source = "./modules/security_group"

  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  allowed_web_cidrs   = var.allowed_web_cidrs
  allowed_ssh_cidrs   = var.allowed_ssh_cidrs
  app_port            = var.app_port
}
