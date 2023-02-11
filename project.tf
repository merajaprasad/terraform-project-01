terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAZZL5CGKF6NGC6FFW"
  secret_key = "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"
}


########   VPC  ########
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

######### Internet gateway ########

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "main"
  }
}


####### Subnet #############

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

############# Aws Route table ###############
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "example"
  }
}

############# Security Group ##################

resource "aws_security_group" "sg" {
  name        = "my_sg_group"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "all traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids = null
    self = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "outbound rules"
    prefix_list_ids = null
    self = null
  }

  tags = {
    Name = "allow_tls"
  }
}


########## Aws Route table association ################

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}


########### Ec2 section ###########

resource "aws_instance" "s1" {
  ami           = "ami-01a4f99c4ac11b03c"
  instance_type = "t2.micro"

  tags = {
    Name = "server1"
  }
}





