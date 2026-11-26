locals {
  availability_zones = var.availability_zones
  az_indexes         = { for index, zone in local.availability_zones : zone => index }
}

# Provides the isolated IP address space and routing boundary for this deployment.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# Connects the VPC public subnets to the internet.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

// Creates public subnets in each availability zone.
# Provides internet-facing subnets for the Application Load Balancer and NAT Gateway.
resource "aws_subnet" "public" {
  for_each = local.az_indexes

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value) // means each public subnet gets a unique /24 block within the VPC CIDR ex : 10.0.0.0/16 -> 10.0.0.0/24, 10.0.1.0/24, etc.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

# Keeps Auto Scaling Group instances private while allowing outbound access through NAT.
resource "aws_subnet" "private" {
  for_each = local.az_indexes

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 3) // means each private subnet gets a unique /24 block within the VPC CIDR ex : 10.0.0.0/16 -> 10.0.3.0/24, 10.0.4.0/24, etc.
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
    Tier = "private"
  }
}

# Associates the public subnets with the route table that sends internet traffic to the IGW.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

# Provides the default internet route for resources in public subnets.
#adds a rule to that table: send traffic destined for 0.0.0.0/0 (anywhere outside the VPC) through the Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Applies public routing to each public subnet.
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Assigns a stable public IPv4 address to the lab's single NAT Gateway, its address is provided through an Elastic IP dynamically .
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }
}

# Gives private EC2 instances outbound internet access without assigning them public IP addresses.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[local.availability_zones[0]].id

  tags = {
    Name = "${var.name_prefix}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

# Associates private subnets with the route table that sends outbound internet traffic through NAT.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-private-rt"
  }
}

# Provides the private subnets' default outbound route through the NAT Gateway.
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Applies private routing to each private subnet.
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
