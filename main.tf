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
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet"
  }
}

#Gateway
resource "aws_internet_gateway" "B-H-IGW" {
  vpc_id = aws_vpc.B-H-VPC.id
tags = {
    Name = "b-h-igw"
  }
}

#Route Table
resource "aws_route_table" "b-h-route-table" {
  vpc_id = aws_vpc.B-H-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.B-H-IGW.id
  }

  tags = {
    Name = "main"
  }
}

#Route table to subnet assoc
resource "aws_route_table_association" "table-to-subnet-public" {
  subnet_id = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.b-h-route-table.id
}

#security group
resource "aws_security_group" "B-H-SG" {
  name = "web-sg"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.B-H-VPC.id

  #SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  #HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
