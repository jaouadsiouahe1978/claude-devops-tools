# RDS - Managed Database

# DB Subnet Group (required for RDS in VPC)
resource "aws_db_subnet_group" "main" {
  name_prefix       = "${var.project_name}-db-"
  subnet_ids        = [aws_subnet.private.id, aws_subnet.public.id]
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier            = "${var.project_name}-db"
  engine                = var.db_engine
  engine_version        = "15.4"
  instance_class        = var.db_instance_class
  allocated_storage     = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  # Backup
  backup_retention_period = 7  # Keep backups for 7 days
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Performance
  multi_az               = false  # Set to true for production
  skip_final_snapshot    = true   # Don't create final snapshot on destroy (dev only)

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "${var.project_name}-postgres"
  }

  depends_on = [aws_db_subnet_group.main]
}

# Parameter Group (optional - for custom PostgreSQL settings)
resource "aws_db_parameter_group" "postgres" {
  name_prefix = "${var.project_name}-pg-"
  family      = "postgres15"
  description = "PostgreSQL parameter group"

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/4}"
  }

  tags = {
    Name = "${var.project_name}-pg-params"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Apply parameter group to RDS instance
resource "aws_db_instance" "postgres_with_params" {
  count                   = 0  # Set to 1 if you want to use custom parameters
  identifier              = "${var.project_name}-db"
  engine                  = var.db_engine
  engine_version          = "15.4"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  parameter_group_name    = aws_db_parameter_group.postgres.name
  publicly_accessible     = false
  skip_final_snapshot     = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}

# Option Group (for optional database features)
# resource "aws_db_option_group" "postgres" {
#   name_prefix              = "${var.project_name}-og-"
#   option_group_description = "Option group for PostgreSQL"
#   engine_name              = var.db_engine
#   major_engine_version     = "15"
#
#   tags = {
#     Name = "${var.project_name}-option-group"
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
