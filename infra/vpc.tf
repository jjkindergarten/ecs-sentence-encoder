

resource "aws_vpc" "ecs-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.name_prefix}-ecs-vpc"
  }
}

resource "aws_internet_gateway" "vpc-internet-gateway" {
  vpc_id = aws_vpc.ecs-vpc.id
    tags = {
        Name = "${var.name_prefix}-ecs-vpc-internet-gateway"
  }
}

resource "aws_route_table" "vpc-route-table"{
  vpc_id = aws_vpc.ecs-vpc.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-internet-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.vpc-internet-gateway.id
  }

  tags = {
    Name = "${var.name_prefix}-ecs-vpc-route-table"
  }
}

#resource "aws_security_group" "subnet-security-group" {
#  name        = "${var.name_prefix}-ecs-security-group"
#  description = "Allow TLS inbound traffic"
#  vpc_id      = aws_vpc.ecs-vpc.id
#
#  ingress {
#    description      = "HTTPS"
#    from_port        = 443
#    to_port          = 443
#    protocol         = "tcp"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  ingress {
#    description      = "HTTP"
#    from_port        = 80
#    to_port          = 80
#    protocol         = "tcp"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#    ingress {
#    description      = "SSH"
#    from_port        = 22
#    to_port          = 22
#    protocol         = "tcp"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  tags = {
#    Name = "${var.name_prefix}-ecs-security-group"
#  }
#}

resource "aws_subnet" "vpc_subnet_1" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "${var.name_prefix}-${var.region}-ecs-subnet-1"
  }
}

resource "aws_subnet" "vpc_subnet_2" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "${var.name_prefix}-${var.region}-ecs-subnet-2"
  }
}

resource "aws_route_table_association" "associate-1" {
  subnet_id = aws_subnet.vpc_subnet_1.id
  route_table_id = aws_route_table.vpc-route-table.id
}

resource "aws_route_table_association" "associate-2" {
  subnet_id = aws_subnet.vpc_subnet_2.id
  route_table_id = aws_route_table.vpc-route-table.id
}

#resource "aws_network_interface" "subnet-1-ni" {
#  subnet_id   = aws_subnet.vpc_subnet_1.id
#  private_ips = ["10.0.1.20"]
#  security_groups = [aws_security_group.subnet-security-group.id]
#
#  tags = {
#    Name = "primary_network_interface"
#  }
#}
#
#resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.subnet-1-ni.id
#   associate_with_private_ip = "10.0.1.20"
#   depends_on                = [aws_internet_gateway.vpc-internet-gateway]
#}
#
#output "server_public_ip" {
#   value = aws_eip.one.public_ip
#}
