variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_name_cidr" {
  description = "VPC name and CIDR Block"
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "public_subnet_1_config" {
  description = "Public subnet 1 config"

  type = object({
    cidr_block = string
    az         = string
  })

}

variable "public_subnet_2_config" {
  description = "Public subnet 2 config"

  type = object({
    cidr_block = string
    az         = string
  })

}

variable "private_subnet_1_config" {
  description = "Private subnet 1 config"

  type = object({
    cidr_block = string
    az         = string
  })
}

variable "private_subnet_2_config" {
  description = "Private subnet 2 config"

  type = object({
    cidr_block = string
    az         = string
  })
}

variable "sg_public_ssh" {
  description = "Security Group configuration for Public Subnet SSH"

  type = object({
    type                     = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    cidr_blocks              = list(string)
    source_security_group_id = optional(string, "")
    description              = string
  })
}

variable "sg_public_instance_egress" {
  description = "Security Group configuration for Public Subnet SSH"

  type = object({
    type                     = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    cidr_blocks              = list(string)
    source_security_group_id = optional(string, "")
    description              = string
  })
}

variable "sg_public_alb_ingress" {
  description = "Security Group configuration for Application Load Balancer Ingress"
  type = object({
    type                     = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    source_security_group_id = optional(string, "")
    description              = string
  })
}


variable "ec2_public" {
  description = "Configuration for a webserver in the public subnet"

  type = object({
    ami_id        = string
    instance_type = string
    key_name      = optional(string, null)

  })
}

variable "db_instance_config" {
  description = "Configuration fo RDS Instance"

  type = object({
    db_name        = string
    instance_class = string
    username       = string
    password       = string
  })
}


