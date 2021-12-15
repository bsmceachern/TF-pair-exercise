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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  key_name = "tform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUoBebW9GknB6xkfVfR/9uDPXgVUFvN1bxzxhEt7O6i7AZysaPeqNO5HaNyHb2/HNlB34JgmBikCcdAyx+Xhlu9gr69x4jxHA5OQN3RBxU22pKxd6yjafA57ASw65hy6IgjTXdcsOW8YYq3vafgWpu9Kfh42X+YAjLHVrAES+OIPvfKILrdNvLDOzYcUcawcMSVW9EM4W32oVW6w9jbY8mUE4wefEppv7vlKPUxXTiFgnTHXgk7ipKBzzjnySEATuuBHEqjrsY1Z0KTKxVk0AHr+bUJZJI3ttCqmlYt53OU8TUPiTwXx9YiuaM57sJRuznE1XDjr8moaeyFaAs3oddLPO286nz74rRnsRX+AG5e/CP26lDFcMDAYqSxxbd/w946oYkLuZar8wU7UQUCaiKKhZWCiNR9upkwgRBU5Yh7ct5ZirwsftIeNhmF2yIRYw2FBnHs0TbvCjwctM9oj17uTom4SOhn3koqPqZRfyT552U4VjU5nRtJ09sAInjqvk= tform-key"
}

resource "aws_instance" "B-H-EC2" {
  ami = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  key_name = "tform"
  security_groups = [ aws_security_group.B-H-SG.id ]

  tags = {
    Name = "B-H-EC2"
  }
  subnet_id = aws_subnet.subnet-public.id


  user_data = "${file("install.sh")}"
}
