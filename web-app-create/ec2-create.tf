provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "web_app_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "web_app_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.web_app_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${path.module}/${var.key_name}.pem"
  content         = tls_private_key.web_app_key.private_key_pem
  file_permission = "0400"
}

resource "aws_security_group" "web_sg" {
  name        = "web-app-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web App Security Group"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_subnet" {
  vpc_id           = data.aws_vpc.default.id
  availability_zone = var.availability_zone
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.web_app_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = data.aws_subnet.default_subnet.id

  tags = {
    Name = "Terraform EC2 Instance"
  }
}
