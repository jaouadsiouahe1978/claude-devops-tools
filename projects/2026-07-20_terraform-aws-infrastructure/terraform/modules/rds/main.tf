# RDS DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# RDS MySQL Database
resource "aws_db_instance" "main" {
  identifier     = "${var.app_name}-${var.environment}-db"
  engine         = "mysql"
  engine_version = "8.0.35"

  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = "gp2"
  storage_encrypted    = false

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  skip_final_snapshot       = true
  publicly_accessible       = false
  multi_az                  = false
  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "mon:04:00-mon:05:00"
  enable_cloudwatch_logs_exports = ["error", "general"]

  tags = {
    Name = "${var.app_name}-${var.environment}-db"
  }
}
