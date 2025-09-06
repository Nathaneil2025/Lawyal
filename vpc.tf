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

# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# Public subnet
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

# Private subnet
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

# Elastic IP for NAT Gateway
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"   # ✅ replaces deprecated 'vpc = true'

  tags = {
    Name    = "${var.project_name}-nat-eip"
    Project = var.project_name
  }
}


# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name    = "${var.project_name}-nat"
    Project = var.project_name
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public route table → IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

# Associate public subnet with public RT
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table → NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project_name}-private-rt"
    Project = var.project_name
  }
}

# Associate private subnet with private RT
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
