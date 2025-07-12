# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_service_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false # Security: No public access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# Fargate Profile for system components
resource "aws_eks_fargate_profile" "system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.cluster_name}-system"
  pod_execution_role_arn = var.fargate_pod_execution_role_arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }

  selector {
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }

  tags = {
    Name = "${var.cluster_name}-system-fargate"
  }
}

# Fargate Profile for application workloads
resource "aws_eks_fargate_profile" "apps" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.cluster_name}-apps"
  pod_execution_role_arn = var.fargate_pod_execution_role_arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "default"
  }

  selector {
    namespace = "gateway"
  }

  selector {
    namespace = "backend"
  }

  tags = {
    Name = "${var.cluster_name}-apps-fargate"
  }
}

# Security Group for EKS Cluster
resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}-cluster-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group Rules for Cluster
resource "aws_security_group_rule" "cluster" {
  for_each = var.security_group_rules

  security_group_id = aws_security_group.cluster.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
} 