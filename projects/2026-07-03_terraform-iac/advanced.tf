# Advanced Terraform features (optional)

# 1. CloudWatch Alarms for EC2
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  for_each = toset(aws_instance.web[*].id)

  alarm_name          = "${var.project_name}-cpu-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when CPU exceeds 80%"
  alarm_actions       = []

  dimensions = {
    InstanceId = each.value
  }
}

# 2. CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Alert when RDS CPU exceeds 70%"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.id
  }
}

# 3. SNS Topic for notifications (optional)
# resource "aws_sns_topic" "alerts" {
#   name = "${var.project_name}-alerts"
#
#   tags = {
#     Name = "${var.project_name}-alerts"
#   }
# }

# 4. S3 bucket for Terraform state (optional - remote state)
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}"
#
#   tags = {
#     Name = "${var.project_name}-terraform-state"
#   }
# }
#
# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# 5. DynamoDB for Terraform state locking (optional)
# resource "aws_dynamodb_table" "terraform_locks" {
#   name           = "${var.project_name}-terraform-locks"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
#
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#
#   tags = {
#     Name = "${var.project_name}-terraform-locks"
#   }
# }

# 6. VPC Flow Logs (optional - for monitoring)
# resource "aws_flow_log" "vpc" {
#   iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.main.id
#
#   tags = {
#     Name = "${var.project_name}-vpc-flow-logs"
#   }
# }

# 7. NAT Gateway for Private Subnet (optional - adds cost)
# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.project_name}-nat-eip"
#   }
#   depends_on = [aws_internet_gateway.main]
# }
#
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id
#
#   tags = {
#     Name = "${var.project_name}-nat-gateway"
#   }
#
#   depends_on = [aws_internet_gateway.main]
# }
#
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }
#
#   tags = {
#     Name = "${var.project_name}-private-rt"
#   }
# }
#
# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private.id
# }

# 8. Current AWS account/caller identity
data "aws_caller_identity" "current" {}

# Output for AWS account info
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  description = "ARN of the AWS caller"
  value       = data.aws_caller_identity.current.arn
}
