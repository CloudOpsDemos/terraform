resource "aws_vpc" "k8s-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${terraform.workspace}-k8s-vpc"
  }
}

resource "aws_subnet" "k8s-sub-pub-2a" {
  vpc_id                  = aws_vpc.k8s-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${terraform.workspace}-k8s-sub-pub-1a"
  }
}

resource "aws_subnet" "k8s-sub-priv-2b" {
  vpc_id                  = aws_vpc.k8s-vpc.id
  cidr_block              = "10.0.100.0/24"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "${terraform.workspace}-k8s-sub-priv-1b"
  }
}

resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "${terraform.workspace}-k8s-igw"
  }
}

resource "aws_route_table" "k8s-rt" {
  vpc_id = aws_vpc.k8s-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "k8s-rt"
  }
}

resource "aws_route_table_association" "k8s-rta-pub-1a" {
  subnet_id      = aws_subnet.k8s-sub-pub-2a.id
  route_table_id = aws_route_table.k8s-rt.id
}

resource "aws_route_table_association" "k8s-rta-priv-1b" {
  subnet_id      = aws_subnet.k8s-sub-priv-2b.id
  route_table_id = aws_route_table.k8s-rt.id
}

resource aws_main_route_table_association "k8s-rta-vpc" {
  vpc_id         = aws_vpc.k8s-vpc.id
  route_table_id = aws_route_table.k8s-rt.id
}
