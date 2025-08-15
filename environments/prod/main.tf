#VPC AND SUBNETS
###################
module "prod_vpc" {
  source = "git::https://github.com/dre8210/terraform-aws-modules.git//modules/vpc?ref=0.13.0"

  vpc_config = {
    cidr_block = var.vpc_name_cidr.cidr_block
    name       = var.vpc_name_cidr.name
  }

  public_subnet_config = {
    public_subnet_1 = {
      cidr_block = var.public_subnet_1_config.cidr_block
      az         = var.public_subnet_1_config.az
    }

    public_subnet_2 = {
      cidr_block = var.public_subnet_2_config.cidr_block
      az         = var.public_subnet_2_config.az
    }
  }

  private_subnet_config = {
    private_subnet_1 = {
      cidr_block = var.private_subnet_1_config.cidr_block
      az         = var.private_subnet_1_config.az
    }

    private_subnet_2 = {
      cidr_block = var.private_subnet_2_config.cidr_block
      az         = var.private_subnet_2_config.az
    }
  }
}

# APPLICATION LOAD BALANCER SECURITY GROUP 
##########################################
resource "aws_security_group" "prod_alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = module.dev_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "dev-alb-sg"
  }

  depends_on = [module.prod_vpc]
}

#SECURITY GROUPS
##################
module "prod_security_group" {
  source = "git::https://github.com/dre8210/terraform-aws-modules.git//modules/security-group?ref=0.13.0"

  vpc_id = module.prod_vpc.vpc_id

  security_group_config_public = {
    ssh_ingress = {
      type        = var.sg_public_ssh.type
      protocol    = var.sg_public_ssh.protocol
      from_port   = var.sg_public_ssh.from_port
      to_port     = var.sg_public_ssh.to_port
      cidr_blocks = var.sg_public_ssh.cidr_blocks
      description = var.sg_public_ssh.description
    }

    instance_egress = {
      type        = var.sg_public_instance_egress.type
      protocol    = var.sg_public_instance_egress.protocol
      from_port   = var.sg_public_instance_egress.from_port
      to_port     = var.sg_public_instance_egress.to_port
      cidr_blocks = var.sg_public_instance_egress.cidr_blocks
      description = var.sg_public_instance_egress.description

    }

    alb_ingress = {
      type                     = var.sg_public_alb_ingress.type
      protocol                 = var.sg_public_alb_ingress.protocol
      from_port                = var.sg_public_alb_ingress.from_port
      to_port                  = var.sg_public_alb_ingress.to_port
      cidr_blocks              = null
      source_security_group_id = aws_security_group.prod_alb_sg.id
      description              = var.sg_public_alb_ingress.description
    }
  }

  depends_on = [module.prod_vpc, aws_security_group.prod_alb_sg]
}

#WEBSERVER - EC2 INSTANCES
#############################
module "prod_webserver" {
  source = "git::https://github.com/dre8210/terraform-aws-modules.git//modules/ec2?ref=0.13.0"

  instance_config = {
    public_instance = {
      ami_id                 = var.ec2_public.ami_id
      instance_type          = var.ec2_public.instance_type
      subnet_id              = module.prod_vpc.public_subnets_ids[0]
      vpc_security_group_ids = [module.prod_security_group.public_security_group_id]
      associate_public_ip    = true
      key_name               = var.ec2_public.key_name
      user_data              = <<-EOF
  #!/bin/bash
  # Update system packages
  apt-get update -y && sudo apt-get upgrade -y

  # Install dependencies
  apt-get install -y nginx git

  # Clone your GitHub repository
  # Replace with your repo URL (HTTPS or SSH)
  rm -rf /var/www/html
  git clone https://github.com/dre8210/terraform_landing_page.git /var/www/html


  # Set permissions
  chown -R www-data:www-data /var/www/html
  chmod -R 755 /var/www/html

  # Start and enable Nginx
  systemctl start nginx
  systemctl enable nginx
EOF
    }
  }

  owners = ["amazon"]

  default_tags = {
    Made_By = "Carl Andrews"
  }

  depends_on = [module.prod_security_group, module.prod_vpc]
}

#RDS DATABASE
#################
resource "aws_db_subnet_group" "prod_db_subnet_group" {
  name       = "prod-db-subnet-group"
  subnet_ids = [module.prod_vpc.private_subnets_ids[0], module.prod_vpc.private_subnets_ids[1]]

  tags = {
    Name = "Prod DB Subnet Group"
  }

  depends_on = [module.prod_vpc]
}

resource "aws_db_instance" "prod_db" {
  allocated_storage    = 10
  db_name              = var.db_instance_config.db_name
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_config.instance_class
  username             = var.db_instance_config.username
  password             = var.db_instance_config.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.prod_db_subnet_group.name
  availability_zone    = var.private_subnet_1_config.az

  tags = {
    Name = "Prod DB Instance"
  }

  depends_on = [aws_db_subnet_group.prod_db_subnet_group]
}

#APPLICATION LOAD BALANCER RESOURCES
####################################
resource "aws_lb_target_group" "prod_app_tg" {
  name        = "dev-app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "prod-app-target-group"
  }

  depends_on = [module.prod_vpc]
}

resource "aws_lb" "prod_app_alb" {
  name               = "prod-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.prod_alb_sg.id]
  subnets            = [module.prod_vpc.public_subnets_ids[0], module.prod_vpc.public_subnets_ids[1]]

  enable_deletion_protection = false

  tags = {
    Name = "prod-app-alb"
  }

  depends_on = [aws_security_group.prod_alb_sg, module.prod_vpc]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.prod_app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_app_tg.arn
  }

  depends_on = [aws_lb.prod_app_alb, aws_lb_target_group.prod_app_tg]
}

resource "aws_lb_target_group_attachment" "prod_app_tg_attachment" {
  target_group_arn = aws_lb_target_group.prod_app_tg.arn
  target_id        = module.prod_webserver.instance_id[0]
  port             = 80

  depends_on = [module.prod_webserver, aws_lb_target_group.prod_app_tg]
}
