# EC2 Instances

# EC2 Key Pair (you'll need to create this manually or import)
# For production, create the key separately and import it:
# resource "aws_key_pair" "main" {
#   key_name   = "${var.project_name}-key"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

# User data script to install basic tools
locals {
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e

              # Update system
              yum update -y

              # Install basic tools
              yum install -y curl wget git vim

              # Install Docker (optional)
              # amazon-linux-extras install docker -y
              # systemctl start docker
              # systemctl enable docker

              # Install Node.js (optional)
              # curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
              # yum install -y nodejs

              # Create app directory
              mkdir -p /app

              # Simple HTTP server
              cat > /app/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                <title>DevOps Infrastructure</title>
                <style>
                  body { font-family: Arial; text-align: center; margin-top: 50px; }
                  .container { background: #f0f0f0; padding: 20px; border-radius: 5px; }
                  h1 { color: #FF9900; }
                  code { background: #eee; padding: 10px; display: block; margin: 10px 0; }
                </style>
              </head>
              <body>
                <div class="container">
                  <h1>✅ Terraform Infrastructure Active</h1>
                  <p>Instance: <strong>EC2</strong></p>
                  <p>Environment: <strong>${var.environment}</strong></p>
                  <p>Project: <strong>${var.project_name}</strong></p>
                  <p>Region: <strong>${var.aws_region}</strong></p>
                  <code>Deployed with Terraform - DevOps Training</code>
                </div>
              </body>
              </html>
              HTML

              # Start simple Python HTTP server
              cd /app
              nohup python3 -m http.server 80 > /var/log/http-server.log 2>&1 &
              EOF
  )
}

# EC2 Instances
resource "aws_instance" "web" {
  count                = var.ec2_count
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # Uncomment if using key pair:
  # key_name             = aws_key_pair.main.key_name

  user_data = local.user_data

  # Enable CloudWatch monitoring
  monitoring = true

  # Associate public IP
  associate_public_ip_address = true

  # Root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-web-${count.index + 1}-root"
    }
  }

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Elastic IP for EC2 (optional - for static public IP)
resource "aws_eip" "web" {
  count    = var.ec2_count
  instance = aws_instance.web[count.index].id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}
