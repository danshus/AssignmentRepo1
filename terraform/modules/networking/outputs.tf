output "peering_connection_id" {
  description = "The ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.main.id
}

output "peering_connection_status" {
  description = "The status of the VPC peering connection"
  value       = aws_vpc_peering_connection.main.accept_status
}

output "vpc1_to_vpc2_security_group_id" {
  description = "The ID of the security group for VPC 1 to VPC 2 communication"
  value       = aws_security_group.vpc1_to_vpc2.id
}

output "vpc2_from_vpc1_security_group_id" {
  description = "The ID of the security group for VPC 2 accepting traffic from VPC 1"
  value       = aws_security_group.vpc2_from_vpc1.id
} 