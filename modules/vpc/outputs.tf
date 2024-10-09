output "vpc" {
  value = ibm_is_vpc.vpc
}

output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "default_security_group" {
  value = ibm_is_vpc.vpc.default_security_group
}

output "vpn_subnet_id" {
  value = ibm_is_subnet.vpn_subnet.id
}

output "vpn_subnet_cidr" {
  value = ibm_is_subnet.vpn_subnet.ipv4_cidr_block
}

output "compute_subnet_id" {
  value = ibm_is_subnet.compute_subnet.id
}

output "compute_subnet_cidr" {
  value = ibm_is_subnet.compute_subnet.ipv4_cidr_block
}

output "vpc_crn" {
  value = ibm_is_vpc.vpc.crn
}

output "default_security_group_name" {
  value = "${var.name}-default-sg"
}