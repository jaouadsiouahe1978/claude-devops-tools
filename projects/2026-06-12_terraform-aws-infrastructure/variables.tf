variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environnement (dev/staging/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment doit être dev, staging ou prod."
  }
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "devops-app"
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "appdb"
  sensitive   = true
}

variable "db_username" {
  description = "Utilisateur admin RDS"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe admin RDS"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Le mot de passe doit faire au moins 8 caractères."
  }
}

variable "enable_public_ip" {
  description = "Attribuer une IP publique aux instances EC2"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Jours de rétention des backups RDS"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "La rétention doit être entre 1 et 35 jours."
  }
}

variable "tags" {
  description = "Tags à appliquer à toutes les ressources"
  type        = map(string)
  default = {
    Owner   = "devops-team"
    Version = "1.0"
  }
}
