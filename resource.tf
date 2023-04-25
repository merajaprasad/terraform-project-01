resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "mainvpc"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "mainsubnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mainigw"
  }
}

resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "mainroutetable"
  }

}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myroutetable.id
}


resource "aws_security_group" "mysg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mainsg"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-06e46074ae430fba6"
  instance_type = var.instance_type
  count = var.instance_count
  subnet_id                   = aws_subnet.mysubnet.id
  vpc_security_group_ids      = [aws_security_group.mysg.id]
  associate_public_ip_address = true

  tags = {
    Name = var.tags
  }
}



