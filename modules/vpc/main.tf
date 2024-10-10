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

# Takes the /16 provided and divides in to 3 /24 prefixes
resource "ibm_is_vpc_address_prefix" "prefix" {
  count      = local.zones
  name       = "${var.name}-${local.vpc_zones[count.index].zone}-prefix"
  zone       = local.vpc_zones[count.index].zone
  vpc        = ibm_is_vpc.vpc.id
  cidr       = cidrsubnet(var.site_address_prefix, 8, count.index)
  is_default = true
}

resource "ibm_is_public_gateway" "gateway" {
  count          = local.zones
  name           = "${var.name}-${local.vpc_zones[count.index].zone}-prefix"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.vpc_zones[count.index].zone
  tags           = concat(var.tags, ["zone:${local.vpc_zones[count.index].zone}"])
}

# Creates a /27 from each address prefix = /24 expanded by 3 = 27
resource "ibm_is_subnet" "subnet" {
  count           = local.zones
  depends_on      = [ibm_is_vpc_address_prefix.prefix]
  name            = "${var.name}-${local.vpc_zones[count.index].zone}-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = local.vpc_zones[count.index].zone
  resource_group  = var.resource_group_id
  ipv4_cidr_block = cidrsubnet(ibm_is_vpc_address_prefix.prefix[count.index].cidr, 3, count.index)
  tags            = concat(var.tags, ["zone:${local.vpc_zones[count.index].zone}"])
}
