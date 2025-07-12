# VPC Peering Connection
resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.vpc_id_1
  peer_vpc_id = var.vpc_id_2
  auto_accept = true
}

# Route table entries for VPC 1 to VPC 2
resource "aws_route" "vpc1_to_vpc2" {
  count                     = length(var.route_table_ids_1)
  route_table_id            = var.route_table_ids_1[count.index]
  destination_cidr_block    = var.vpc_cidr_2
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# Route table entries for VPC 2 to VPC 1
resource "aws_route" "vpc2_to_vpc1" {
  count                     = length(var.route_table_ids_2)
  route_table_id            = var.route_table_ids_2[count.index]
  destination_cidr_block    = var.vpc_cidr_1
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# Security Group for VPC 1 (Gateway) to allow outbound to VPC 2 (Backend)
resource "aws_security_group" "vpc1_to_vpc2" {
  name_prefix = "vpc1-to-vpc2-"
  vpc_id      = var.vpc_id_1

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_2]
    description = "Allow HTTP traffic to VPC 2"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_2]
    description = "Allow HTTPS traffic to VPC 2"
  }
}

# Security Group for VPC 2 (Backend) to allow inbound from VPC 1 (Gateway)
resource "aws_security_group" "vpc2_from_vpc1" {
  name_prefix = "vpc2-from-vpc1-"
  vpc_id      = var.vpc_id_2

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_1]
    description = "Allow HTTP traffic from VPC 1"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_1]
    description = "Allow HTTPS traffic from VPC 1"
  }
} 