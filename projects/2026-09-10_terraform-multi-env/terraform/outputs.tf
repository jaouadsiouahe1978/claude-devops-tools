output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = aws_subnet.main[*].id
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.app[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = aws_instance.app[*].private_ip
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "environment_info" {
  description = "Environment information"
  value = {
    environment = var.environment
    region      = var.aws_region
    project     = var.project_name
    vpc_id      = aws_vpc.main.id
    instance_count = var.instance_count
  }
}

output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = <<-EOT
    Environment: ${var.environment}
    Project: ${var.project_name}
    Region: ${var.aws_region}

    VPC:
      ID: ${aws_vpc.main.id}
      CIDR: ${aws_vpc.main.cidr_block}

    Compute:
      Instances: ${var.instance_count}
      Type: ${var.instance_type}

    Load Balancer:
      DNS: ${aws_lb.main.dns_name}
  EOT
}
