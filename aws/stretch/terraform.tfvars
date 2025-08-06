 # List of regions
#regions = ["us-east-1", "us-east-2", "us-west-2"]
#vpc_cidrs   = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]

region_info = {
  "region0" = {
    region   = "us-east-1"
    vpc_cidr = "10.190.0.0/16"
    az_info  = [
      {az = "us-east-1a", az_cidr = "10.190.1.0/24"},
      {az = "us-east-1b", az_cidr = "10.190.2.0/24"},
      {az = "us-east-1c", az_cidr = "10.190.3.0/24"}
    ]
  }
  "region1" = {
    region   = "us-east-2"
    vpc_cidr = "10.1.0.0/16"
    az_info  = [
      {az = "us-east-2a", az_cidr = "10.1.1.0/24"},
      {az = "us-east-2b", az_cidr = "10.1.2.0/24"},
      {az = "us-east-2c", az_cidr = "10.1.3.0/24"}
    ]
  }
  "region2" = {
    region   = "us-west-2"
    vpc_cidr = "10.2.0.0/16"
    az_info  = [
      {az = "us-west-2a", az_cidr = "10.2.1.0/24"},
      {az = "us-west-2b", az_cidr = "10.2.2.0/24"},
    ]
  }
}


owner = "cnelson"

# Regions with their respective Availability Zones and CIDR ranges for Redpanda
#redpanda_regions_and_azs = {
#  "region0" = [
#    {"az" = "us-east-1a", "cidr" = "10.0.1.0/24"},
#    {"az" = "us-east-1b", "cidr" = "10.0.2.0/24"},
#    {"az" = "us-east-1c", "cidr" = "10.0.3.0/24"}
#  ]
#  "region1" = [
#    {"az" = "us-east-2a", "cidr" = "10.1.1.0/24"},
#    {"az" = "us-east-2b", "cidr" = "10.1.2.0/24"},
#    {"az" = "us-east-2c", "cidr" = "10.1.3.0/24"}
#  ]
#  "region2" = [
#    {"az" = "us-west-2a", "cidr" = "10.2.1.0/24"},
#    {"az" = "us-west-2b", "cidr" = "10.2.2.0/24"}
#  ]
#}

# Regions for OMB workers and Prometheus (e.g., deploying only in us-west-2)
omb_regions = ["us-west-2"]

# Subnet CIDR blocks for OMB in specific regions
omb_subnet_cidr_blocks = {
  "us-west-2" = ["10.1.1.0/24", "10.1.2.0/24"]
}

# Number of brokers per availability zone for Redpanda (per-region and per-AZ)
brokers_per_az = {
  "us-east-1" = {
    "us-east-1a" = 2,
    "us-east-1b" = 2,
    "us-east-1c" = 2
  },
  "us-west-2" = {
    "us-west-2a" = 2,
    "us-west-2b" = 2,
    "us-west-2c" = 2
  },
  "eu-central-1" = {
    "eu-central-1a" = 1,
    "eu-central-1b" = 1
  }
}

# Instance type for Redpanda brokers, OMB workers, and Prometheus
instance_type = "t3.medium"

# Redpanda-specific AMI IDs (Replace with actual Redpanda AMIs or use a standard AMI)
ami_id = "ami-0c55b159cbfafe1f0"

# SSH key for access
ssh_key = "~/.ssh/redpanda_aws.pub"
