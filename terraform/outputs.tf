output "gateway_cluster_endpoint" {
  description = "Endpoint for EKS gateway cluster"
  value       = module.eks_gateway.cluster_endpoint
}

output "backend_cluster_endpoint" {
  description = "Endpoint for EKS backend cluster"
  value       = module.eks_backend.cluster_endpoint
}

output "gateway_vpc_id" {
  description = "Gateway VPC ID"
  value       = module.vpc_gateway.vpc_id
}

output "backend_vpc_id" {
  description = "Backend VPC ID"
  value       = module.vpc_backend.vpc_id
}

output "vpc_peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = module.vpc_peering.peering_connection_id
} 