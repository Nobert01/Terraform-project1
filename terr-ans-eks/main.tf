module "network" {
  source             = "./modules/network"
  vpc_cidr           = var.vpc_cidr
  vpc-name           = var.vpc-name
  igw-name           = var.igw-name
  pub_cidr_block     = var.pub_cidr_block
  private_cidr_block = var.private_cidr_block
}

# module "eks" {
#   source = "./modules/eks"

# }