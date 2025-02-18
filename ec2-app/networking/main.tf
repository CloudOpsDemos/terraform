# Common resources for networking (vpc, subnets, IGW, RT, RT association)
# TODO: define conditions for NAT, private and public subnets, elastic IP.

variable "project_name" {}
variable "env" {}
variable "vpc_cidr" {}
variable "cidr_public_subnets" {}
variable "cidr_private_subnets" {}
variable "availability_zones" {}

# Setup VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Setup public subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.cidr_public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.cidr_public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public RT
resource "aws_route_table" "public-rt" {
  count       = length(aws_subnet.public_subnets) > 0 ? 1 : 0
  vpc_id      = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Public RT association
resource "aws_route_table_association" "public-rt-association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public-rt[0].id
}
