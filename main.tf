terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
  access_key = "AKIA3NJYJ6QBYJ67KZGI"
  secret_key = "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"
  
}



# Create a VPC
resource "aws_vpc" "cyber_vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "SubnetA" {
  vpc_id = aws_vpc.cyber_vpc.id
  availability_zone = "eu-west-1a"
  cidr_block = "10.10.1.0/24"
  tags = {
    Name = "SubnetA"
  }
}
resource "aws_subnet" "SubnetB" {
  vpc_id = aws_vpc.cyber_vpc.id
  availability_zone = "eu-west-1b"
  cidr_block = "10.10.2.0/24"
  tags = {
    Name = "SubnetB"
  }
}


resource "aws_security_group" "internal_ssh" {
  name        = "internal_ssh"
  description = "Allow SSH only between subnets"
  vpc_id      = aws_vpc.cyber_vpc.id
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.SubnetA.cidr_block, aws_subnet.SubnetB.cidr_block]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ami_from_instance" "custom_ami" {
  name               = "custom-ami"
  source_instance_id = aws_instance.Wizard_A.id
}


resource "aws_instance" "Wizard_A"{
   ami = "ami-0db1de538d84beea0"
   instance_type = "t3.micro"
   subnet_id = aws_subnet.SubnetA.id
   vpc_security_group_ids = [aws_security_group.internal_ssh.id]
   associate_public_ip_address = false
 }
resource "aws_instance" "Wizard_B"{
   ami = "ami-0db1de538d84beea0"
   instance_type = "t3.micro"
   subnet_id = aws_subnet.SubnetB.id
   vpc_security_group_ids = [aws_security_group.internal_ssh.id]
   associate_public_ip_address = false
 }
terraform {
  backend "s3" {
    bucket         = "bootcampbucketflorinel"
    key            = "episode2/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "Terraform-locks"
    encrypt        = true
  }
}



