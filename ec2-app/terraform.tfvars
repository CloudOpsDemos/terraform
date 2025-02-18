project_name        = "ec2-test"
env                 = "${terraform.workspace}"
vpc_cidr            = "10.0.0.0/16"
cidr_public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
cidr_private_subnets = ["10.0.128.0/24", "10.0.129.0/24"]
region              = "us-west-2"
availability_zones  = ["us-west-2a", "us-west-2b"]
