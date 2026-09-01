# Optional EC2 instances for testing the network setup
# Uncomment to deploy test instances

/*
# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Public EC2 Instance in Public Subnet 1 (Web Server)
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Web Server - $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
  )

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-web-server"
    }
  )
}

# Private EC2 Instance in Private Subnet 1 (Application Server)
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Application Server - $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
  )

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-app-server"
    }
  )
}

# Output EC2 instances details
output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web_server.private_ip
}

output "app_server_private_ip" {
  description = "Private IP of the application server"
  value       = aws_instance.app_server.private_ip
}

*/
