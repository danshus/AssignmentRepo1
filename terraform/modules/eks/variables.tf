variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster (must be private subnets for Fargate)"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
  default     = []
}

variable "cluster_service_role_arn" {
  description = "ARN of existing IAM role for EKS cluster service (required - cannot create roles)"
  type        = string
}

variable "fargate_pod_execution_role_arn" {
  description = "ARN of existing IAM role for Fargate pod execution (required - cannot create roles)"
  type        = string
}

variable "security_group_rules" {
  description = "Map of security group rules"
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {}
}