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

output "cluster_security_group_id" {
  description = "The ID of the security group for the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "fargate_profiles" {
  description = "Map of Fargate profiles"
  value = {
    system = aws_eks_fargate_profile.system
    apps   = aws_eks_fargate_profile.apps
  }
} 