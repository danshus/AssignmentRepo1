terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module for Gateway
module "vpc_gateway" {
  source = "./modules/vpc"

  vpc_cidr = var.gateway_vpc_cidr

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = var.gateway_private_subnets
  public_subnets  = var.gateway_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true # Cost optimization - single NAT per VPC
}

# VPC Module for Backend
module "vpc_backend" {
  source = "./modules/vpc"

  vpc_cidr = var.backend_vpc_cidr

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = var.backend_private_subnets
  public_subnets  = var.backend_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true # Cost optimization - single NAT per VPC
}

# VPC Peering for secure cross-VPC communication
module "vpc_peering" {
  source = "./modules/networking"

  vpc_id_1 = module.vpc_gateway.vpc_id
  vpc_id_2 = module.vpc_backend.vpc_id

  vpc_cidr_1 = var.gateway_vpc_cidr
  vpc_cidr_2 = var.backend_vpc_cidr

  route_table_ids_1 = module.vpc_gateway.private_route_table_ids
  route_table_ids_2 = module.vpc_backend.private_route_table_ids
}

# EKS Cluster for Gateway
module "eks_gateway" {
  source = "./modules/eks"

  cluster_name    = "eks-gateway"
  cluster_version = "1.32"

  vpc_id         = module.vpc_gateway.vpc_id
  subnet_ids     = module.vpc_gateway.private_subnets
  public_subnets = module.vpc_gateway.public_subnets

  # Leave empty to try creating roles first, provide ARNs if IAM permissions are restricted
  # cluster_service_role_arn = "arn:aws:iam::ACCOUNT_ID:role/existing-eks-service-role"
  # node_group_role_arn      = "arn:aws:iam::ACCOUNT_ID:role/existing-nodegroup-role"

  node_groups = {
    gateway-nodes = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = "gateway"
        NodeGroup   = "gateway-nodes"
      }
    }
  }

  security_group_rules = {
    ingress_nodes_443 = {
      description = "Node groups security group"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# EKS Cluster for Backend
module "eks_backend" {
  source = "./modules/eks"

  cluster_name    = "eks-backend"
  cluster_version = "1.32"

  vpc_id     = module.vpc_backend.vpc_id
  subnet_ids = module.vpc_backend.private_subnets

  # Leave empty to try creating roles first, provide ARNs if IAM permissions are restricted  
  # cluster_service_role_arn = "arn:aws:iam::ACCOUNT_ID:role/existing-eks-service-role"
  # node_group_role_arn      = "arn:aws:iam::ACCOUNT_ID:role/existing-nodegroup-role"

  node_groups = {
    backend-nodes = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = "backend"
        NodeGroup   = "backend-nodes"
      }
    }
  }

  # Restrict backend cluster to only accept traffic from gateway cluster
  security_group_rules = {
    ingress_from_gateway = {
      description = "Allow traffic from gateway EKS nodes"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = [var.gateway_vpc_cidr]
    }
  }
} 