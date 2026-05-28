# EC2 Instance dans le subnet public
resource "aws_instance" "nginx" {
  count                       = var.instance_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  associate_public_ip_address = true
  monitoring                  = var.enable_monitoring

  # User data pour installer Nginx
  user_data = file("${path.module}/user_data.sh")

  # Volume root
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.environment}-nginx-root-volume"
    }
  }

  # Metadata options pour IMDSv2 (sécurité)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.environment}-nginx-${count.index + 1}"
    Role = "WebServer"
  }

  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public_1
  ]
}

# Elastic IP pour l'instance (optionnel mais recommandé)
resource "aws_eip" "nginx" {
  count    = var.instance_count
  domain   = "vpc"
  instance = aws_instance.nginx[count.index].id

  tags = {
    Name = "${var.environment}-nginx-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}
