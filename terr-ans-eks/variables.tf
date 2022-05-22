#cidr block for cali-vpc
variable "vpc_cidr" {
  type        = string
  description = "cidr_block for cali-vpc"
}

variable "vpc-name" {
  type        = string
  description = "vpc-name for the eks cluster"
}

variable "igw-name" {
  type        = string
  description = "internet gateway name for the eks cluster"
}

# variable "pub_cidr_block" {
#   type        = list(string)
#   description = "vpc-name for the eks cluster"
#   default     = ["10.0.1.0/24", "10.0.50.0/24"]
# }

# variable "private_cidr_block" {
#   type        = list(string)
#   description = "vpc-name for the eks cluster"
#   default     = ["10.0.100.0/24", "10.0.150.0/24"]
# }

variable "eks_cluster_name" {
  description = "name of eks cluster"
  type = string
}
