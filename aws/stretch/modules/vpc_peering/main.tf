variable "vpc_id" {
  description = "ID of the local VPC"
  type        = string
}

variable "peer_vpc_id" {
  description = "ID of the peer VPC"
  type        = string
}

variable "peer_region" {
  description = "The region of the peer VPC"
  type        = string
}

variable "route_table_id" {
  description = "ID of the route table to update"
  type        = string
}

variable "peer_route_table_id" {
  description = "ID of the route table to update"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the peer VPC"
  type        = string
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the peer VPC"
  type        = string
}





# Create a peering connection between 2 VPC's
resource "aws_vpc_peering_connection" "peer_connection" {
  provider     = aws.region-req    # Provider for the requesting region
  vpc_id       = var.vpc_id
  peer_vpc_id  = var.peer_vpc_id
  peer_region  = var.peer_region
  auto_accept  = false

  tags = {
    Name = "Peering-stretch-to-${var.peer_region}"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_connection_accepter" {
  provider                  = aws.region-acc # Provider for the accepting region
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
  auto_accept               = true  # Accept the peering connection automatically

  tags = {
    Name = "Accepting peering connection"
  }
}


# Route in Requester's VPC (region-req) to the Accepter's VPC (region-acc)
resource "aws_route" "requester_to_accepter" {
  provider               = aws.region-req  # Provider for the requesting region
  route_table_id         = var.route_table_id
  destination_cidr_block = var.peer_vpc_cidr  # CIDR block of the peer VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}

# Route in Accepter's VPC (region-acc) to the Requester's VPC (region-req)
resource "aws_route" "accepter_to_requester" {
  provider               = aws.region-acc  # Provider for the accepting region
  route_table_id         = var.peer_route_table_id  # Route table for the accepting VPC
  destination_cidr_block = var.vpc_cidr  # CIDR block of the requester VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}
