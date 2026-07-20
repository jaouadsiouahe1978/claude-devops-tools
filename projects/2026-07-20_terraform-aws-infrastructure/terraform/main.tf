module "vpc" {
  source = "./modules/vpc"

  app_name    = var.app_name
  environment = var.environment
  aws_region  = var.aws_region
}

module "ec2" {
  source = "./modules/ec2"

  app_name              = var.app_name
  environment           = var.environment
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.vpc.web_security_group_id
  cloudwatch_group_name = aws_cloudwatch_log_group.ec2_logs.name

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/rds"

  app_name            = var.app_name
  environment         = var.environment
  allocated_storage   = var.rds_allocated_storage
  instance_class      = var.rds_instance_class
  vpc_id              = module.vpc.vpc_id
  db_subnet_ids       = [module.vpc.private_subnet_id]
  security_group_id   = module.vpc.rds_security_group_id
  database_name       = var.database_name
  database_username   = var.database_username
  database_password   = var.database_password

  depends_on = [module.vpc]
}

# CloudWatch Log Group for EC2
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/${var.app_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "${var.app_name}-ec2-logs"
  }
}

# CloudWatch Alarm - CPU Usage
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.app_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Alert when EC2 CPU exceeds 70%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = module.ec2.instance_id
  }
}

# CloudWatch Alarm - RDS CPU Usage
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.app_name}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "Alert when RDS CPU exceeds 75%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = module.rds.instance_id
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average", label = "EC2 CPU %" }],
            [".", "NetworkIn", { stat = "Sum", label = "Network In" }],
            [".", "NetworkOut", { stat = "Sum", label = "Network Out" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Metrics"

          dimensions = {
            InstanceId = module.ec2.instance_id
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average", label = "RDS CPU %" }],
            [".", "DatabaseConnections", { stat = "Average", label = "Connections" }],
            [".", "FreeStorageSpace", { stat = "Average", label = "Free Storage (bytes)" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Metrics"

          dimensions = {
            DBInstanceIdentifier = module.rds.instance_id
          }
        }
      }
    ]
  })
}
