output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}



output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_iam_role_name" {
  description = "The name of the IAM role for the EKS cluster"
  value       = var.cluster_service_role_arn != "" ? split("/", var.cluster_service_role_arn)[1] : aws_iam_role.cluster[0].name
}

output "cluster_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  value       = local.cluster_role_arn
}

output "node_iam_role_name" {
  description = "The name of the IAM role for the EKS node groups"
  value       = var.node_group_role_arn != "" ? split("/", var.node_group_role_arn)[1] : aws_iam_role.node[0].name
}

output "node_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS node groups"
  value       = local.node_role_arn
}

output "cluster_security_group_id" {
  description = "The ID of the security group for the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "The ID of the security group for the EKS nodes"
  value       = aws_security_group.node.id
}

output "node_groups" {
  description = "Map of EKS node groups"
  value       = aws_eks_node_group.main
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = var.cluster_name == "eks-gateway" ? aws_lb.gateway_alb[0].dns_name : null
} 