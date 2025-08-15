aws_region = "us-east-1"


vpc_name_cidr = {
  cidr_block = "10.0.0.0/16"
  name = "dev_env_vpc"
}

private_subnet_1_config = {
  cidr_block = "10.0.1.0/24"
  az = "us-east-1a"
}

private_subnet_2_config = {
  cidr_block = "10.0.3.0/24"
  az = "us-east-1b"
}

public_subnet_1_config = {
  cidr_block = "10.0.2.0/24"
    az         = "us-east-1a"
}

public_subnet_2_config = {
  cidr_block = "10.0.4.0/24"
    az         = "us-east-1b"
}

sg_public_ssh = {
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = [ "0.0.0.0/0" ]
  description = "Allow SSH access from anywhere"
}

sg_public_instance_egress  = {
  type = "egress"
  protocol = "-1"
  from_port = 0
  to_port = 0
  cidr_blocks = [ "0.0.0.0/0" ]
  description = "Allow Instance to access internet"
}

sg_public_alb_ingress = {
  type = "ingress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  description = "Allow traffic from the ALB SG"
}

ec2_public = {
  ami_id = "ami-020cba7c55df1f615"
  instance_type = "t3.micro"
  key_name = "terraform-keypair"
}

db_instance_config = {
  db_name = "private_db"
  instance_class = "db.t3.micro"
  username = "foo"
  password = "foobarbaz"
}