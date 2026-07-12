output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_min_size" {
  description = "Minimum size of ASG"
  value       = aws_autoscaling_group.main.min_size
}

output "asg_max_size" {
  description = "Maximum size of ASG"
  value       = aws_autoscaling_group.main.max_size
}

output "asg_desired_capacity" {
  description = "Desired capacity of ASG"
  value       = aws_autoscaling_group.main.desired_capacity
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Latest version of Launch Template"
  value       = aws_launch_template.main.latest_version_number
}

output "security_group_alb_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb.id
}

output "security_group_ec2_id" {
  description = "Security Group ID for EC2"
  value       = aws_security_group.ec2.id
}

output "app_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}/api/hello"
}

output "health_check_url" {
  description = "URL to check application health"
  value       = "http://${aws_lb.main.dns_name}/health"
}
