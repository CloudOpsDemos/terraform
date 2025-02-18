resource "aws_security_group" "ec2_sg_ssh_http_public" {
  name = "${var.project_name}-ec2-sg-public"
  description = "Enable port 22 (ssh), 80 (http), 443 (https), ICMP (All)"
  vpc_id = module.networking.vpc_id

  # ssh from anywhere
  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks  = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # http from anywhere
  ingress {
    description = "Allow http"
    cidr_blocks  = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # https from anywhere
  ingress {
    description = "Allow http"
    cidr_blocks  = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  # icmp from anywhere
  ingress {
    description = "Allow icmp"
    cidr_blocks  = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
  }

  # outgoing requests
  egress {
    description = "Allow outgoing requests"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "ec2_sg_ssh_http_private" {
  name = "${var.project_name}-ec2-sg-private"
  description = "Enable port 22 (ssh), 80 (http), 443 (https), ICMP (All)"
  vpc_id = module.networking.vpc_id

  # ssh from anywhere
  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks  = [var.vpc_cidr]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # http from anywhere
  ingress {
    description = "Allow http"
    cidr_blocks  = [var.vpc_cidr]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # https from anywhere
  ingress {
    description = "Allow http"
    cidr_blocks  = [var.vpc_cidr]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  # outgoing requests
  egress {
    description = "Allow outgoing requests"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# Security Group for RDS
resource "aws_security_group" "rds_mysql_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow access to RDS from EC2 present in public subnet"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # replace with your EC2 instance security group CIDR block
  }

  tags = {
    Name = "Security Groups to allow traffic on port 3306"
  }
}

resource "aws_security_group" "ec2_sg_python_api" {
  name        = "${var.project_name}-sg-python_api"
  description = "Enable the Port 5000 for python api"
  vpc_id      = module.networking.vpc_id

  # ssh for terraform remote exec
  ingress {
    description = "Allow traffic on port 5000"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
  }

  tags = {
    Name = "Security Groups to allow traffic on port 5000"
  }
}
