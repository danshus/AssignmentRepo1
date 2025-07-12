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

# EKS Node Groups
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.subnet_ids
  version         = var.cluster_version

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_capacity
    max_size     = each.value.max_capacity
    min_size     = each.value.min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  labels = each.value.labels
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

# Security Group for Node Groups
resource "aws_security_group" "node" {
  name_prefix = "${var.cluster_name}-node-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group Rules for Nodes
resource "aws_security_group_rule" "node" {
  for_each = var.security_group_rules

  security_group_id = aws_security_group.node.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}

# Application Load Balancer for Gateway cluster only
resource "aws_lb" "gateway_alb" {
  count              = var.cluster_name == "eks-gateway" ? 1 : 0
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "${var.cluster_name}-alb"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  count       = var.cluster_name == "eks-gateway" ? 1 : 0
  name_prefix = "${var.cluster_name}-alb-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "gateway_tg" {
  count    = var.cluster_name == "eks-gateway" ? 1 : 0
  name     = "${var.cluster_name}-tg"
  port     = 30080 # NodePort for the service
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.cluster_name}-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "gateway_listener" {
  count             = var.cluster_name == "eks-gateway" ? 1 : 0
  load_balancer_arn = aws_lb.gateway_alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_tg[0].arn
  }
}

# Autoscaling Group Attachment for Gateway ALB
resource "aws_autoscaling_attachment" "gateway_asg_attachment" {
  count                  = var.cluster_name == "eks-gateway" ? 1 : 0
  autoscaling_group_name = aws_eks_node_group.main["gateway"].resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.gateway_tg[0].arn
} 