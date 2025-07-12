

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "gateway_vpc_cidr" {
  description = "CIDR block for Gateway VPC"
  type        = string
  default     = "10.0.0.0/20"
}

variable "backend_vpc_cidr" {
  description = "CIDR block for Backend VPC"
  type        = string
  default     = "10.1.0.0/20"
}

variable "gateway_private_subnets" {
  description = "Private subnets for Gateway VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "gateway_public_subnets" {
  description = "Public subnets for Gateway VPC (for NAT Gateway)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "backend_private_subnets" {
  description = "Private subnets for Backend VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "backend_public_subnets" {
  description = "Public subnets for Backend VPC (for NAT Gateway)"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
} 