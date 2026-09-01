output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_1_id" {
  description = "ID of Public Subnet 1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_1_cidr" {
  description = "CIDR block of Public Subnet 1"
  value       = aws_subnet.public_1.cidr_block
}

output "public_subnet_2_id" {
  description = "ID of Public Subnet 2"
  value       = aws_subnet.public_2.id
}

output "public_subnet_2_cidr" {
  description = "CIDR block of Public Subnet 2"
  value       = aws_subnet.public_2.cidr_block
}

output "private_subnet_1_id" {
  description = "ID of Private Subnet 1"
  value       = aws_subnet.private_1.id
}

output "private_subnet_1_cidr" {
  description = "CIDR block of Private Subnet 1"
  value       = aws_subnet.private_1.cidr_block
}

output "private_subnet_2_id" {
  description = "ID of Private Subnet 2"
  value       = aws_subnet.private_2.id
}

output "private_subnet_2_cidr" {
  description = "CIDR block of Private Subnet 2"
  value       = aws_subnet.private_2.cidr_block
}

output "public_route_table_id" {
  description = "ID of the Public Route Table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the Private Route Table"
  value       = aws_route_table.private.id
}

output "web_security_group_id" {
  description = "ID of the Web Security Group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "ID of the Application Security Group"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "ID of the Database Security Group"
  value       = aws_security_group.database.id
}

output "availability_zones" {
  description = "Availability zones used"
  value       = data.aws_availability_zones.available.names[0:2]
}
