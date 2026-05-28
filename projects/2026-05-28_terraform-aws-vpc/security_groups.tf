# Security Group pour Nginx Web Server
resource "aws_security_group" "nginx" {
  name_prefix = "${var.environment}-nginx-"
  description = "Security group pour instances Nginx"
  vpc_id      = aws_vpc.main.id

  # Règles entrantes (Inbound)
  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS depuis Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH depuis Internet (pour debugging)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règles sortantes (Outbound) - Par défaut tout est autorisé
  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-nginx-sg"
  }
}

# Security Group pour instances privées
resource "aws_security_group" "private" {
  name_prefix = "${var.environment}-private-"
  description = "Security group pour instances privées"
  vpc_id      = aws_vpc.main.id

  # Autoriser le trafic depuis le Security Group Nginx
  ingress {
    description     = "Trafic depuis Nginx"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  # SSH depuis la VPC (10.0.0.0/16)
  ingress {
    description = "SSH depuis la VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Tout le trafic sortant
  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-private-sg"
  }
}
