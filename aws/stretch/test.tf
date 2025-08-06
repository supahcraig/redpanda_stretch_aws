# Provider for us-east-1
provider "aws" {
  region = var.region_info.region0.region
  #region = var.regions[0]
  alias  = "region0"
}

# Provider for us-west-2
provider "aws" {
  #region = var.regions[1]
  region = var.region_info.region1.region
  alias  = "region1"
}

# Provider for eu-central-1
provider "aws" {
  #region = var.regions[2]
  region = var.region_info.region2.region
  alias  = "region2"
}





############ VARIABLE DECLARATIONS ###############

variable "region_info" {
  description = "Map of region-specific information including region name and VPC CIDR"
  type = map(object({
    region   = string
    vpc_cidr = string
    az_info  = list(object({
      az      = string
      az_cidr = string
    }))
  }))
}


variable "owner" {
  description = "name of the owner of the resource, to be used in naming & tagging"
  type        = string
}




############# VPCs / Subnets / Security Groups ################

# Call the networking module for each region, passing the provider and CIDR block
module "networking_region0" {
  source     = "./modules/networking"
  vpc_cidr_block = var.region_info.region0.vpc_cidr
  region         = var.region_info.region0.region

  providers = {
    aws = aws.region0
  }

  az_info = [
    for item in var.region_info.region0.az_info : {
      az   = item.az
      cidr = item.az_cidr
    }
  ]

  vpc_cidrs = [for region_key in keys(var.region_info) : var.region_info[region_key].vpc_cidr]

  owner = var.owner
}

module "networking_region1" {
  source     = "./modules/networking"
  vpc_cidr_block = var.region_info.region1.vpc_cidr
  region         = var.region_info.region1.region

  providers = {
    aws = aws.region1
  }

  az_info = [
    for item in var.region_info.region1.az_info : {
      az   = item.az
      cidr = item.az_cidr
    }
  ]

  vpc_cidrs= [for region_key in keys(var.region_info) : var.region_info[region_key].vpc_cidr]

  owner = var.owner
}

module "networking_region2" {
  source     = "./modules/networking"
  vpc_cidr_block = var.region_info.region2.vpc_cidr
  region         = var.region_info.region2.region

  providers = {
    aws = aws.region2
  }

  az_info = [
    for item in var.region_info.region2.az_info : {
      az   = item.az
      cidr = item.az_cidr
    }
  ]

  vpc_cidrs = [for region_key in keys(var.region_info) : var.region_info[region_key].vpc_cidr]

  owner = var.owner
}

############### Peering ####################

# Create peering connections between all 3 VPC's
# Also creates the necessary routes in both directions

module "vpc_peering_0_to_1" {
  source = "./modules/vpc_peering"
  vpc_id         = module.networking_region0.vpc_id          # VPC that is requesting the peering connection
  vpc_cidr       = var.region_info.region0.vpc_cidr          # cidr of requesting VPC
  route_table_id = module.networking_region0.route_table_id  # Route table of requesting VPC

  peer_region         = var.region_info.region1.region             # Region that accepts the peering request
  peer_vpc_id         = module.networking_region1.vpc_id           # VPC id of the target of the peering request
  peer_vpc_cidr       = var.region_info.region1.vpc_cidr            # cidr of the target of the peering requestr
  peer_route_table_id = module.networking_region1.route_table_id   # route table id of the peering request

  providers     = {
    aws.region-req = aws.region0  # provider for the requesting VPC
    aws.region-acc = aws.region1  # provider for the accepting VPC
  }
}

module "vpc_peering_0_to_2" {
  source = "./modules/vpc_peering"
  vpc_id         = module.networking_region0.vpc_id  # Local VPC in region0
  vpc_cidr       = var.region_info.region0.vpc_cidr
  route_table_id = module.networking_region0.route_table_id     # Route table to update

  peer_region         = var.region_info.region2.region
  peer_vpc_id         = module.networking_region2.vpc_id  # Peer VPC in region1
  peer_vpc_cidr       = var.region_info.region2.vpc_cidr
  peer_route_table_id = module.networking_region2.route_table_id

  providers     = {
    aws.region-req = aws.region0  # provider for the requesting VPC
    aws.region-acc = aws.region2  # provider for the accepting VPC
  }
}

module "vpc_peering_1_to_2" {
  source = "./modules/vpc_peering"
  vpc_id         = module.networking_region1.vpc_id  # Local VPC in region0
  vpc_cidr       = var.region_info.region1.vpc_cidr
  route_table_id = module.networking_region1.route_table_id     # Route table to update

  peer_region         = var.region_info.region2.region
  peer_vpc_id         = module.networking_region2.vpc_id  # Peer VPC in region1
  peer_vpc_cidr       = var.region_info.region2.vpc_cidr
  peer_route_table_id = module.networking_region2.route_table_id

  providers     = {
    aws.region-req = aws.region1  # provider for the requesting VPC
    aws.region-acc = aws.region2  # provider for the accepting VPC
  }
}
