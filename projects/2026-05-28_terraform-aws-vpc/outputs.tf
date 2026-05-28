output "vpc_id" {
  description = "ID de la VPC créée"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_1_id" {
  description = "ID du subnet public 1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "ID du subnet public 2"
  value       = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
  description = "ID du subnet privé 1"
  value       = aws_subnet.private_1.id
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nginx_security_group_id" {
  description = "ID du Security Group Nginx"
  value       = aws_security_group.nginx.id
}

output "private_security_group_id" {
  description = "ID du Security Group Privé"
  value       = aws_security_group.private.id
}

output "nginx_instance_ids" {
  description = "IDs des instances Nginx"
  value       = aws_instance.nginx[*].id
}

output "nginx_instance_private_ips" {
  description = "IPs privées des instances Nginx"
  value       = aws_instance.nginx[*].private_ip
}

output "nginx_instance_public_ips" {
  description = "IPs publiques des instances Nginx"
  value       = aws_instance.nginx[*].public_ip
}

output "nginx_elastic_ips" {
  description = "Elastic IPs des instances Nginx"
  value       = aws_eip.nginx[*].public_ip
}

output "nginx_instance_ip" {
  description = "IP publique de la première instance Nginx (pour curl)"
  value       = try(aws_eip.nginx[0].public_ip, aws_instance.nginx[0].public_ip, "")
}

output "ssh_command" {
  description = "Commande SSH pour accéder à l'instance"
  value       = "ssh -i /path/to/key.pem ubuntu@${try(aws_eip.nginx[0].public_ip, aws_instance.nginx[0].public_ip, '')}"
}

output "nginx_url" {
  description = "URL pour accéder à Nginx"
  value       = "http://${try(aws_eip.nginx[0].public_ip, aws_instance.nginx[0].public_ip, '')}"
}

output "ami_id" {
  description = "AMI utilisée pour les instances"
  value       = data.aws_ami.ubuntu.id
}

output "terraform_state_info" {
  description = "Information sur l'état Terraform"
  value       = "État stocké dans: terraform.tfstate"
}
