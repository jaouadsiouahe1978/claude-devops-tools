variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nom du projet pour les tags"
  type        = string
  default     = "devops-elb"
}

variable "vpc_cidr" {
  description = "CIDR block pour la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Nombre minimum d'instances dans l'ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Nombre maximum d'instances dans l'ASG"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Nombre désiré d'instances dans l'ASG"
  type        = number
  default     = 2
}
