terraform {
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
    }
}

provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "B-H-VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Branden-and-Hunters-VPC"
  }
}

#Subnet
resource "aws_subnet" "subnet-public" {
  vpc_id     = aws_vpc.B-H-VPC.id
  cidr_block = "10.0.0.0/16"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet"
  }
}

