variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Profil AWS CLI"
  type        = string
  default     = "default"
}

variable "vpc_cidr" {
  description = "CIDR block pour la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR pour le subnet public 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR pour le subnet public 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR pour le subnet privé 1"
  type        = string
  default     = "10.0.10.0/24"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Nombre d'instances EC2 à créer"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Activer CloudWatch monitoring détaillé"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags à appliquer à toutes les ressources"
  type        = map(string)
  default = {
    Project = "DevOps-Training"
    Creator = "Jaouad"
    Date    = "2026-05-28"
  }
}
