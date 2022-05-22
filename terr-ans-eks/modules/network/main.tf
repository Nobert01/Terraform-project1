locals {
  public-subnet-name  = "cali-subnet1"
  private-subnet-name = "cali-subnet2"
  availability_zone   = ["us-east-1a", "us-east-1b"]
}

# VPC for the cali eks cluster
resource "aws_vpc" "cali-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name                                            = var.vpc-name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"

  }
}

resource "aws_internet_gateway" "cali-igw" {
  vpc_id = aws_vpc.cali-vpc.id


  tags = {
    Name = var.igw-name
  }
}

#public subnet for cali-eks cluster
resource "aws_subnet" "cali-pub-subnet" {
  count             = length(var.pub_cidr_block)
  vpc_id            = aws_vpc.cali-vpc.id
  cidr_block        = element(var.pub_cidr_block, count.index)
  availability_zone = element(local.availability_zone, count.index)

  tags = {
    Name                                            = local.public-subnet-name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1

  }
}

#private subnet for cali-eks cluster
resource "aws_subnet" "cali-private-subnet" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.cali-vpc.id
  cidr_block        = element(var.private_cidr_block, count.index)
  availability_zone = element(local.availability_zone, count.index)

  tags = {
    Name                                            = local.private-subnet-name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1

  }
}

resource "aws_nat_gateway" "NGW" {
  subnet_id = aws_subnet.cali-pub-subnet[0].id
  allocation_id = aws_eip.NGW.id

  tags = {
    Name = "cali-NAT-GW"
  }
  depends_on = [aws_internet_gateway.cali-igw]
}
resource "aws_eip" "NGW" {
  vpc      = true
}


resource "aws_route_table" "cali-pub-RT" {
  vpc_id = aws_vpc.cali-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cali-igw.id
  }

  tags = {
    Name = "cali-pub-RT"
  }
}

resource "aws_route_table_association" "pub" {
  count          = length(var.pub_cidr_block)
  subnet_id      = element(aws_subnet.cali-pub-subnet.*.id, count.index)
  route_table_id = aws_route_table.cali-pub-RT.id
}
#Private subnet configuration


resource "aws_route_table" "cali-priv-RT" {
  vpc_id = aws_vpc.cali-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "cali-priv-RT"
  }
}

resource "aws_route_table_association" "priv" {
  count          = length(local.availability_zone)
  subnet_id      = element(aws_subnet.cali-private-subnet.*.id, count.index)
  route_table_id = aws_route_table.cali-priv-RT.id
}



