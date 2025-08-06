variable "region" {
  description = "Region where the resource will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC/subnets"
  type        = string
}

variable "vpc_cidrs" {
  description = "List of all the VPC cidr blocks"
  type        = list(string)
}

variable "az_info" {
  description = "list of AZ/cidr range mapping for subnets"
  type        = list(object({
    az   = string
    cidr = string
  }))
}

variable "owner" {
  description = "owner name used in object naming and tagging"
  type        = string
}

# Get public IP of this machine
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


# Define the VPC resource
resource "aws_vpc" "vpc" {
  provider             = aws
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-${var.region}-stretch"
    owner = var.owner
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

# Create the subnets
resource "aws_subnet" "subnet" {
  for_each = { for item in var.az_info : item.az => item }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true  # For public subnets (set to false for private)

  tags = {
    Name        = "Subnet-${var.region}-stretch-${each.value.az}"
    owner       = var.owner
  }
}


# Create the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW-${var.region}"
  }
}

# Create the route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "PublicRouteTable-${var.region}"
  }
}


# Create the route to the IGW
resource "aws_route" "default" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"  # Default route to the internet
  gateway_id             = aws_internet_gateway.igw.id
}


# Associate the route table to each of our subnets
resource "aws_route_table_association" "public_association" {
  for_each = { for subnet in var.az_info : subnet.az => subnet }

  subnet_id      = aws_subnet.subnet[each.key].id  # Reference to the subnet
  route_table_id = aws_route_table.public_rt.id   # Associate the route table with the subnet
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = aws_route_table.public_rt.id
}


##### Security Groups #######


# Security Group for VPC
resource "aws_security_group" "sg" {
  provider = aws
  name        = "redpanda-security-group"
  description = "Security group for the VPC"
  vpc_id      = aws_vpc.vpc.id

  # Ingress rules for specific ports from all VPC CIDRs
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs  # CIDR blocks from all 3 VPCs
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs
  }

  ingress {
    from_port   = 9644
    to_port     = 9644
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs
  }

  ingress {
    from_port   = 33145
    to_port     = 33145
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidrs
  }

  # SSH access from local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }  

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "Redpanda-Security-Group-${var.region}"
  }
}

# Output the Security Group ID
output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.sg.id
}
