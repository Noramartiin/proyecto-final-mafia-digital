# ----------------------------------------------------------------------------------------------------------------------
# AWS VPC, SUBNETS & ROUTES
# ----------------------------------------------------------------------------------------------------------------------

# VPC
resource "aws_vpc" "vpc-app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-app"
  }
}

# Subnets
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.vpc-app.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.vpc-app.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "subnet-3" {
  vpc_id            = aws_vpc.vpc-app.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-3"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-app.id

  tags = {
    Name = "internet-gateway"
  }
}

# Routes
resource "aws_route_table" "app-route" {
  vpc_id = aws_vpc.vpc-app.id

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route to internet"
  }
}

resource "aws_route_table_association" "route1" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.app-route.id
}

resource "aws_route_table_association" "route2" {
  subnet_id = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.app-route.id
}

resource "aws_route_table_association" "route3" {
  subnet_id = aws_subnet.subnet-3.id
  route_table_id = aws_route_table.app-route.id
}
