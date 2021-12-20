# variables for the rancher server ec2 
variable "awsrancher" {
  type = map(any)
  default = {
    region       = "eu-west-2"
    itype        = "t2.large"
    publicip     = true
    keyname      = "f21"
    secgroupname = "rancher-sg"
  }
}

# public cloud provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = lookup(var.awsrancher, "region")
}

# create a vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "rancher"
  cidr = "10.105.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets  = ["10.105.1.0/24", "10.105.2.0/24", "10.105.3.0/24"]
  private_subnets = ["10.105.4.0/24", "10.105.5.0/24", "10.105.6.0/24"]

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  enable_nat_gateway                     = true

  tags = {
    "Name" = "rancher"
  }
}

# chose operating system for jenkins instance
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# set open ingress ports rules 
variable "ingressrules" {
  type    = list(number)
  default = [22, 80, 443, 8080]
}

# launch security group for the instance
resource "aws_security_group" "rancher-sg" {
  name        = lookup(var.awsrancher, "secgroupname")
  description = lookup(var.awsrancher, "secgroupname")

  // to allow ssh 22, http 80, https 443 and tcp port 8080 transport
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "rancher-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = lookup(var.awsrancher, "itype")
  security_groups             = [aws_security_group.rancher-sg.name]
  associate_public_ip_address = lookup(var.awsrancher, "publicip")
  key_name                    = lookup(var.awsrancher, "keyname")
  user_data                   = file("user-data-rancher.sh")

  vpc_security_group_ids = [
    aws_security_group.rancher-sg.id
  ]
  # connection {
  # type        = "ssh"
  # host        = self.public_ip
  # user        = "ubuntu"
  # private_key = file("~/f21.pem")
  # }

  tags = {
    Name        = "rancher"
    Environment = "dev"
    OS          = "ubuntu"
    Terraform   = "true"
  }

  depends_on = [aws_security_group.rancher-sg]
}

output "ec2instance" {
  value = aws_instance.rancher-server.public_ip
}
