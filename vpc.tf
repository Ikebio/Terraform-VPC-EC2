# VPC
resource "aws_vpc" "ikec7" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Ike-C7"
  }
}

# Public Subnet
resource "aws_subnet" "ike_pub" {
  vpc_id     = aws_vpc.ikec7.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    Name = "ike_pub"
  }
}

# Private Subnet
resource "aws_subnet" "ike_priv" {
  vpc_id     = aws_vpc.ikec7.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ike_priv"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ike_gw" {
  vpc_id = aws_vpc.ikec7.id

  tags = {
    Name = "ike_gw"
  }
}

# Public Rout Table
resource "aws_route_table" "ike_pub_rt" {
  vpc_id = aws_vpc.ikec7.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ike_gw.id
  }

  tags = {
    Name = "Pub_RT_Ike"
  }
}

# Rout Association public subnet
resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.ike_pub.id
  route_table_id = aws_route_table.ike_pub_rt.id
}

# Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  instance                  = aws_instance.ikepriv.id
  associate_with_private_ip = "10.0.0.12"
  depends_on                = [aws_internet_gateway.ike_gw]
}


# NAT GATEWAY FOR PRIVAATE EC2
resource "aws_nat_gateway" "ike_ng" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.ike_pub.id

  tags = {
    Name = "Ike NATGW"
  }
  depends_on = [aws_internet_gateway.ike_gw]
}

# PRIVATE ROUT TABLE
resource "aws_route_table" "ike_priv_rt" {
  vpc_id = aws_vpc.ikec7.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ike_ng.id
  }

  tags = {
    Name = "Priv_RT_Ike"
  }
}

# Rout Association private subnet
resource "aws_route_table_association" "priv" {
  subnet_id      = aws_subnet.ike_priv.id
  route_table_id = aws_route_table.ike_priv_rt.id
}