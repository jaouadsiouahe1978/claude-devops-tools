output "alb_dns_name" {
  description = "DNS name de l'Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN de l'Application Load Balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.main.arn
}

output "asg_name" {
  description = "Nom de l'Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_id" {
  description = "ID de l'Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "launch_template_id" {
  description = "ID du Launch Template"
  value       = aws_launch_template.main.id
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = aws_subnet.public[*].id
}

output "alb_security_group_id" {
  description = "ID du security group ALB"
  value       = aws_security_group.alb.id
}

output "instance_security_group_id" {
  description = "ID du security group des instances"
  value       = aws_security_group.instance.id
}

output "application_url" {
  description = "URL pour accéder à l'application via l'ALB"
  value       = "http://${aws_lb.main.dns_name}"
}
