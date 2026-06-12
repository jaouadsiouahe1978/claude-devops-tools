output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR du VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnets" {
  description = "IDs des subnets publics"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs des subnets privés"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "DNS name de l'Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN de l'ALB"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID de l'ALB (pour Route53)"
  value       = aws_lb.main.zone_id
}

output "rds_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = aws_db_instance.postgres.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "Adresse RDS (pour connexion)"
  value       = aws_db_instance.postgres.address
  sensitive   = true
}

output "rds_port" {
  description = "Port RDS"
  value       = aws_db_instance.postgres.port
}

output "app_instance_ids" {
  description = "IDs des instances EC2"
  value       = aws_instance.app[*].id
}

output "app_private_ips" {
  description = "IPs privées des instances EC2"
  value       = aws_instance.app[*].private_ip
}

output "security_group_alb_id" {
  description = "ID du security group ALB"
  value       = aws_security_group.alb.id
}

output "security_group_app_id" {
  description = "ID du security group App"
  value       = aws_security_group.app.id
}

output "security_group_rds_id" {
  description = "ID du security group RDS"
  value       = aws_security_group.rds.id
}

output "connection_string" {
  description = "Connection string pour PostgreSQL"
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}"
  sensitive   = true
}

output "alb_url" {
  description = "URL à visiter pour accéder à l'application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "terraform_summary" {
  description = "Résumé de l'infrastructure créée"
  value = {
    environment     = var.environment
    region          = var.aws_region
    project_name    = var.project_name
    vpc_cidr        = var.vpc_cidr
    instance_type   = var.instance_type
    db_instance     = var.db_instance_class
    alb_available   = "http://${aws_lb.main.dns_name}"
  }
}
