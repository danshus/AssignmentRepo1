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

# EKS Cluster for Gateway (Fargate)
module "eks_gateway" {
  source = "./modules/eks"

  cluster_name    = "eks-gateway"
  cluster_version = "1.32"

  vpc_id         = module.vpc_gateway.vpc_id
  subnet_ids     = module.vpc_gateway.private_subnets
  public_subnets = module.vpc_gateway.public_subnets

  # Use existing IAM roles - cannot create or manage IAM resources
  cluster_service_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksClusterRole"
  fargate_pod_execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSFargatePodExecutionRole"

  security_group_rules = {
    ingress_gateway = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.1.0.0/16"]
      description = "Gateway HTTP access"
    }
  }
}

# EKS Cluster for Backend (Fargate)
module "eks_backend" {
  source = "./modules/eks"

  cluster_name    = "eks-backend"
  cluster_version = "1.32"

  vpc_id     = module.vpc_backend.vpc_id
  subnet_ids = module.vpc_backend.private_subnets

  # Use existing IAM roles - cannot create or manage IAM resources
  cluster_service_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksClusterRole"
  fargate_pod_execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSFargatePodExecutionRole"

  security_group_rules = {
    ingress_backend = {
      type        = "ingress"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["10.1.0.0/16"]
      description = "Backend service access from gateway"
    }
  }
} 