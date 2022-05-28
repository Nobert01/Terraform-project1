
variable "aws_priv_subnet1_id" {
description = "private subnet id" 
}

variable "aws_pub_subnet1_id" {
description = "public subnet id" 
}

variable "eks-name" {
    description = "terraform eks cluster"
}

variable "eks_cluster_role_name" {
    description = "iam role for eks cluster"
}

variable "eks_SG_name" {
    description = "security group name for eks cluster"
  
}
variable "vpc_id" {
    description = "vpc id for the eks cluster"
  
}