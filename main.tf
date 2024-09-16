locals {
  prefix = var.project_prefix != "" ? var.project_prefix : "${random_string.prefix.0.result}"
  #   ssh_key_ids = var.existing_ssh_key != "" ? [data.ibm_is_ssh_key.sshkey[0].id] : [ibm_is_ssh_key.generated_key[0].id]
  zones = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.ibmcloud_region}-${zone + 1}"
    }
  }


  tags = [
    "provider:ibm",
    "region:${var.ibmcloud_region}"
  ]
}

# If no project prefix is defined, generate a random one 
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  numeric = false
  upper   = false
}

resource "random_string" "vpn_preshared_key" {
  length  = 24
  special = false
}

# If an existing resource group is provided, this module returns the ID, otherwise it creates a new one and returns the ID
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

module "site_a_vpc" {
  source              = "./modules/vpc"
  name                = "${local.prefix}-site-a"
  resource_group_id   = module.resource_group.resource_group_id
  ibmcloud_region     = var.ibmcloud_region
  tags                = concat(local.tags, ["site_a"])
  site_address_prefix = "172.16.0.0/16"
}

module "site_b_vpc" {
  source              = "./modules/vpc"
  name                = "${local.prefix}-site-b"
  resource_group_id   = module.resource_group.resource_group_id
  ibmcloud_region     = var.ibmcloud_region
  tags                = concat(local.tags, ["site_b"])
  site_address_prefix = "192.168.0.0/16"
}

# Add rules to the default security group of the VPCs.
# this is here mainly for an example of the syntax
module "add_rules_to_default_vpc_security_group" {
  depends_on                   = [module.site_a_vpc, module.site_b_vpc]
  source                       = "terraform-ibm-modules/security-group/ibm"
  add_ibm_cloud_internal_rules = true
  use_existing_security_group  = true
  existing_security_group_name = module.site_a_vpc.default_security_group_name
  security_group_rules = [
    {
      name      = "allow-icmp-inbound"
      direction = "inbound"
      icmp = {
        type = 8
      }
      remote = "0.0.0.0/0"
    }
  ]
  tags = local.tags
}

resource "ibm_is_vpn_gateway" "site_a_s2s" {
  name           = "${local.prefix}-site-a-vpn"
  subnet         = module.site_a_vpc.vpc_subnet_id
  mode           = "policy"
  resource_group = module.resource_group.resource_group_id
  tags           = local.tags
}

resource "ibm_is_vpn_gateway" "site_b_s2s" {
  name           = "${local.prefix}-site-b-vpn"
  subnet         = module.site_b_vpc.vpc_subnet_id
  mode           = "policy"
  resource_group = module.resource_group.resource_group_id
  tags           = local.tags
}

resource "ibm_is_vpn_gateway_connection" "site_a_connection" {
  name          = "${local.prefix}-site-a-connection"
  vpn_gateway   = ibm_is_vpn_gateway.site_a_s2s.id
  preshared_key = random_string.vpn_preshared_key.result
  # peer_address  = ibm_is_vpn_gateway.example.public_ip_address # deprecated, replaced with peer block
  # peer_cidrs    = [ibm_is_subnet.example2.ipv4_cidr_block] # deprecated, replaced with peer block
  peer {
    address = ibm_is_vpn_gateway.site_b_s2s.public_ip_address
    cidrs   = [module.site_b_vpc.vpc_subnet_cidr]
  }
  # local_cidrs   = [ibm_is_subnet.example.ipv4_cidr_block] # deprecated, replaced with local block
  local {
    cidrs = [module.site_a_vpc.vpc_subnet_cidr]
  }
}

resource "ibm_is_vpn_gateway_connection" "site_b_connection" {
  name          = "${local.prefix}-site-b-connection"
  vpn_gateway   = ibm_is_vpn_gateway.site_b_s2s.id
  preshared_key = random_string.vpn_preshared_key.result
  # peer_address  = ibm_is_vpn_gateway.example.public_ip_address # deprecated, replaced with peer block
  # peer_cidrs    = [ibm_is_subnet.example2.ipv4_cidr_block] # deprecated, replaced with peer block
  peer {
    address = ibm_is_vpn_gateway.site_a_s2s.public_ip_address
    cidrs   = [module.site_a_vpc.vpc_subnet_cidr]
  }
  # local_cidrs   = [ibm_is_subnet.example.ipv4_cidr_block] # deprecated, replaced with local block
  local {
    cidrs = [module.site_b_vpc.vpc_subnet_cidr]
  }
}