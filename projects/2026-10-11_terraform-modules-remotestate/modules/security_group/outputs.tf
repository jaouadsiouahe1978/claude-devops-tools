output "web_sg_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "Application security group ID"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

output "web_sg_name" {
  description = "Web security group name"
  value       = aws_security_group.web.name
}

output "app_sg_name" {
  description = "App security group name"
  value       = aws_security_group.app.name
}

output "db_sg_name" {
  description = "Database security group name"
  value       = aws_security_group.db.name
}
