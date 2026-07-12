# AWS Configuration
aws_region = "eu-west-1"

# Application Configuration
app_name    = "demo-app"
environment = "dev"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Instance Configuration
instance_type = "t2.micro"

# Auto Scaling Configuration
asg_min_size         = 2
asg_max_size         = 5
asg_desired_capacity = 2

# Application Configuration
container_port = 8080

# Load Balancer Configuration
health_check_path     = "/health"
health_check_interval = 30

# SSH Access (optional - leave empty to disable SSH key requirement)
# key_name = "my-ec2-key-pair"
