resource "aws_vpc" "k8s-vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true

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
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_nat_gateway.k8s-ngw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${terraform.workspace}-k8s-priv-rt"
  }
}

resource "aws_subnet" "k8s-pub" {
  vpc_id            = aws_vpc.k8s-vpc.id
  count             = length(local.availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.k8s-vpc.cidr_block, 8, count.index+1)
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name = "${terraform.workspace}-k8s-pub-${count.index+1}"
  }
}

resource "aws_subnet" "k8s-priv" {
  vpc_id            = aws_vpc.k8s-vpc.id
  count             = length(local.availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.k8s-vpc.cidr_block, 8, count.index+101)
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name = "${terraform.workspace}-k8s-priv-${count.index+1}"
  }
}

resource "aws_route_table_association" "k8s-pub" {
  route_table_id  = aws_vpc.k8s-vpc.default_route_table_id
  count           = length(local.availability_zones)
  subnet_id       = element(aws_subnet.k8s-pub[*].id, count.index)
}

resource "aws_route_table_association" "k8s-priv" {
  route_table_id  = aws_route_table.k8s-priv-rt.id
  count           = length(local.availability_zones)
  subnet_id       = element(aws_subnet.k8s-priv[*].id, count.index)
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

resource "aws_eip" "k8s-eip" {
  vpc = true
  depends_on = [aws_internet_gateway.k8s-igw]

  tags = {
    Name = "${terraform.workspace}-k8s-eip"
  }
}

resource "aws_nat_gateway" "k8s-ngw" {
  subnet_id     = element(aws_subnet.k8s-priv[*].id, 0)
  allocation_id = aws_eip.k8s-eip.id
  depends_on    = [aws_internet_gateway.k8s-igw]

  tags = {
    Name = "${terraform.workspace}-k8s-ngw"
  }
}
