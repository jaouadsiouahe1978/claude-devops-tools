# Outputs - Exporte les valeurs importantes

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "ec2_instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "ec2_public_ips" {
  description = "EC2 instance public IPs"
  value       = aws_instance.web[*].public_ip
}

output "ec2_private_ips" {
  description = "EC2 instance private IPs"
  value       = aws_instance.web[*].private_ip
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "RDS database address (without port)"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.postgres.port
}

output "web_security_group_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

# SSH command for connecting to EC2
output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i /path/to/key.pem ec2-user@${aws_instance.web[0].public_ip}"
  sensitive   = false
}

# Database connection string (without password)
output "db_connection_string" {
  description = "Database connection string (add password manually)"
  value       = "postgresql://${var.db_username}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}"
  sensitive   = false
}
