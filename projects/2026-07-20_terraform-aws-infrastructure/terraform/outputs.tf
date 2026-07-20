output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.vpc.private_subnet_id
}

output "ec2_public_ip" {
  description = "EC2 instance public IP address"
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "EC2 instance private IP address"
  value       = module.ec2.private_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS database port"
  value       = module.rds.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.database_name
}

output "rds_username" {
  description = "RDS master username"
  value       = module.rds.username
  sensitive   = true
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.app_name}-dashboard"
}

output "cloudwatch_alarms_url" {
  description = "URL to CloudWatch alarms"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#alarmsV2:"
}

output "ssh_command" {
  description = "SSH command to connect to EC2 instance"
  value       = "ssh -i ~/.ssh/aws-key.pem ec2-user@${module.ec2.public_ip}"
}

output "web_url" {
  description = "Web server URL"
  value       = "http://${module.ec2.public_ip}"
}
