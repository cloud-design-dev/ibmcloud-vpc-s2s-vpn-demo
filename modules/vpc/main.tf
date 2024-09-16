locals {
  zones = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.ibmcloud_region}-${zone + 1}"
    }
  }
}

data "ibm_is_zones" "regional" {
  region = var.ibmcloud_region
}

resource "ibm_is_vpc" "vpc" {
  name                        = var.name
  resource_group              = var.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management   = var.default_address_prefix
  default_network_acl_name    = "${var.name}-default-acl"
  default_security_group_name = "${var.name}-default-sg"
  default_routing_table_name  = "${var.name}-default-rt"
  tags                        = var.tags
}

resource "ibm_is_vpc_address_prefix" "prefix" {
  name       = "${var.name}-address-prefix"
  zone       = local.vpc_zones[0].zone
  vpc        = ibm_is_vpc.vpc.id
  cidr       = var.site_address_prefix
  is_default = true
}

resource "ibm_is_public_gateway" "gateway" {
  name           = "${var.name}-${local.vpc_zones[0].zone}-pgw"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.vpc_zones[0].zone
  tags           = concat(var.tags, ["zone:${local.vpc_zones[0].zone}"])
}

# Subnet
resource "ibm_is_subnet" "subnet" {
  name                     = "${var.name}-${local.vpc_zones[0].zone}-subnet"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "64"
  public_gateway           = ibm_is_public_gateway.gateway.id
  tags                     = concat(var.tags, ["zone:${local.vpc_zones[0].zone}"])
}