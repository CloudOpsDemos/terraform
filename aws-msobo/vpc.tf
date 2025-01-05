resource "aws_vpc" "k8s-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${terraform.workspace}-k8s-vpc"
  }
}

resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "${terraform.workspace}-k8s-igw"
  }
}

resource "aws_default_route_table" "k8s-pub-rt" {
  default_route_table_id = aws_vpc.k8s-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${terraform.workspace}-k8s-pub-rt"
  }
}

resource "aws_route_table" "k8s-priv-rt" {
  vpc_id = aws_vpc.k8s-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${terraform.workspace}-k8s-priv-rt"
  }
}

resource "aws_subnet" "k8s-pub-1" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "${terraform.workspace}-k8s-pub-1"
  }
}

resource "aws_subnet" "k8s-pub-2" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "${terraform.workspace}-k8s-pub-2"
  }
}

resource "aws_subnet" "k8s-priv-1" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "${terraform.workspace}-k8s-priv-1"
  }
}

resource "aws_subnet" "k8s-priv-2" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-west-2d"

  tags = {
    Name = "${terraform.workspace}-k8s-priv-2"
  }
}

resource "aws_route_table_association" "k8s-pub" {
  for_each = toset([aws_subnet.k8s-pub-1.id, aws_subnet.k8s-pub-2.id])

  subnet_id = each.key
  route_table_id = aws_vpc.k8s-vpc.default_route_table_id
}

resource "aws_route_table_association" "k8s-priv" {
  for_each = toset([aws_subnet.k8s-priv-1.id, aws_subnet.k8s-priv-2.id])

  subnet_id = each.key
  route_table_id = aws_route_table.k8s-priv-rt.id
}

resource "aws_default_network_acl" "k8s-default-nacl" {
  default_network_acl_id = aws_vpc.k8s-vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${terraform.workspace}-k8s-default-nacl"
  }
}

resource "aws_default_security_group" "k8s-default-sg" {
  vpc_id = aws_vpc.k8s-vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-k8s-default-sg"
  }
}
