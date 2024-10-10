locals {
  prefix = var.project_prefix != "" ? var.project_prefix : "${random_string.prefix.0.result}"

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
module "update_site_a_security_group" {
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
    },
    {
      name      = "allow-ssh-inbound"
      direction = "inbound"
      tcp = {
        port_min = 22
        port_max = 22
      }
      remote = "0.0.0.0/0"
    }
  ]
  tags = concat(local.tags, ["site_a"])
}

module "update_site_b_security_group" {
  depends_on                   = [module.site_a_vpc, module.site_b_vpc]
  source                       = "terraform-ibm-modules/security-group/ibm"
  add_ibm_cloud_internal_rules = true
  use_existing_security_group  = true
  existing_security_group_name = module.site_b_vpc.default_security_group_name
  security_group_rules = [
    {
      name      = "allow-icmp-inbound"
      direction = "inbound"
      icmp = {
        type = 8
      }
      remote = "0.0.0.0/0"
    },
    {
      name      = "allow-ssh-inbound"
      direction = "inbound"
      tcp = {
        port_min = 22
        port_max = 22
      }
      remote = "0.0.0.0/0"
    }
  ]
  tags = concat(local.tags, ["site_b"])
}

resource "ibm_is_vpn_gateway" "site_a_s2s" {
  name           = "${local.prefix}-site-a-vpn"
  subnet         = module.site_a_vpc.subnet_ids[0]
  mode           = "policy"
  resource_group = module.resource_group.resource_group_id
  tags           = concat(local.tags, ["site_a"])
}

resource "ibm_is_vpn_gateway" "site_b_s2s" {
  name           = "${local.prefix}-site-b-vpn"
  subnet         = module.site_b_vpc.subnet_ids[0]
  mode           = "policy"
  resource_group = module.resource_group.resource_group_id
  tags           = concat(local.tags, ["site_b"])
}

resource "ibm_is_vpn_gateway_connection" "site_a_connection" {
  name          = "${local.prefix}-site-a-connection"
  vpn_gateway   = ibm_is_vpn_gateway.site_a_s2s.id
  preshared_key = random_string.vpn_preshared_key.result
  peer {
    address = ibm_is_vpn_gateway.site_b_s2s.public_ip_address
    cidrs   = [module.site_b_vpc.subnet_cidrs[0]]
  }
  local {
    cidrs = [module.site_a_vpc.subnet_cidrs[0]]
  }
}

resource "ibm_is_vpn_gateway_connection" "site_b_connection" {
  name          = "${local.prefix}-site-b-connection"
  vpn_gateway   = ibm_is_vpn_gateway.site_b_s2s.id
  preshared_key = random_string.vpn_preshared_key.result
  peer {
    address = ibm_is_vpn_gateway.site_a_s2s.public_ip_address
    cidrs   = [module.site_a_vpc.subnet_cidrs[0]]
  }
  local {
    cidrs = [module.site_b_vpc.subnet_cidrs[0]]
  }
}

module "site_a_compute" {
  source                  = "./modules/compute"
  name                    = "${local.prefix}-a-instance"
  zone                    = local.vpc_zones[0].zone
  vpc_id                  = module.site_a_vpc.vpc_id
  subnet_id               = module.site_a_vpc.subnet_ids[0]
  resource_group_id       = module.resource_group.resource_group_id
  tags                    = concat(local.tags, ["site_a"])
  instance_security_group = module.site_a_vpc.default_security_group
  ssh_key_ids             = [data.ibm_is_ssh_key.sshkey.id]
}

module "site_b_compute" {
  source                  = "./modules/compute"
  name                    = "${local.prefix}-b-instance"
  zone                    = local.vpc_zones[0].zone
  vpc_id                  = module.site_b_vpc.vpc_id
  subnet_id               = module.site_b_vpc.subnet_ids[0]
  resource_group_id       = module.resource_group.resource_group_id
  tags                    = concat(local.tags, ["site_b"])
  instance_security_group = module.site_b_vpc.default_security_group
  ssh_key_ids             = [data.ibm_is_ssh_key.sshkey.id]
}

resource "ibm_is_floating_ip" "site_a" {
  name           = "${local.prefix}-a-fip"
  target         = module.site_a_compute.vnic_id
  resource_group = module.resource_group.resource_group_id
  tags           = concat(local.tags, ["site_a"])
}

resource "ibm_is_floating_ip" "site_b" {
  name           = "${local.prefix}-b-fip"
  target         = module.site_b_compute.vnic_id
  resource_group = module.resource_group.resource_group_id
  tags           = concat(local.tags, ["site_b"])
}

module "ansible" {
  source            = "./ansible"
  site_a_public_ip  = ibm_is_floating_ip.site_a.address
  site_a_private_ip = module.site_a_compute.compute_instance_ip
  site_b_public_ip  = ibm_is_floating_ip.site_b.address
  site_b_private_ip = module.site_b_compute.compute_instance_ip
}

# resource "ansible_host" "site_a_instance" {
#   name   = "${local.prefix}-a-instance"
#   groups = ["site_a"] # Groups this host is part of.
#   variables = {
#     ansible_user = "root"
#     ansible_host = ibm_is_floating_ip.site_a.address
#     hostname     = "${local.prefix}-a-instance"
#   }
# }

# resource "ansible_host" "site_b_instance" {
#   name   = "${local.prefix}-b-instance"
#   groups = ["site_b"] # Groups this host is part of.
#   variables = {
#     ansible_user = "root"
#     ansible_host = ibm_is_floating_ip.site_b.address
#     hostname     = "${local.prefix}-b-instance"
#   }
# }

# resource "ansible_playbook" "ping_a_to_b" {
#   playbook   = "ping.yaml"
#   name   = "${local.prefix}-a-instance"
#   replayable = true
#   groups    = ["site_a"]

#   extra_vars = {
#     target_host = module.site_b_compute.compute_instance_ip
#   }
# }
