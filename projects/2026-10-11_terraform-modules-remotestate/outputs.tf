output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ip" {
  description = "NAT Gateway Elastic IP"
  value       = module.vpc.nat_gateway_ip
}

output "web_sg_id" {
  description = "Web tier security group ID"
  value       = module.security_groups.web_sg_id
}

output "app_sg_id" {
  description = "Application tier security group ID"
  value       = module.security_groups.app_sg_id
}

output "db_sg_id" {
  description = "Database tier security group ID"
  value       = module.security_groups.db_sg_id
}

output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    vpc_id              = module.vpc.vpc_id
    vpc_cidr            = module.vpc.vpc_cidr
    public_subnets     = length(module.vpc.public_subnet_ids)
    private_subnets    = length(module.vpc.private_subnet_ids)
    web_sg              = module.security_groups.web_sg_name
    app_sg              = module.security_groups.app_sg_name
    db_sg               = module.security_groups.db_sg_name
  }
}
