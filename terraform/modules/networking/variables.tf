variable "vpc_id_1" {
  description = "ID of the first VPC"
  type        = string
}

variable "vpc_id_2" {
  description = "ID of the second VPC"
  type        = string
}

variable "vpc_cidr_1" {
  description = "CIDR block of the first VPC"
  type        = string
}

variable "vpc_cidr_2" {
  description = "CIDR block of the second VPC"
  type        = string
}

variable "route_table_ids_1" {
  description = "List of route table IDs in the first VPC"
  type        = list(string)
}

variable "route_table_ids_2" {
  description = "List of route table IDs in the second VPC"
  type        = list(string)
}