resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "dev"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az_public
  map_public_ip_on_launch = true

  tags = {
    Name                                     = "${var.project_name}-public-${var.az_public}"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az_private

  tags = {
    Name                                           = "${var.project_name}-private-${var.az_private}"
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}
