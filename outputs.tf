output "site_a_info" {
  value = {
    vpn_gateway_ip     = ibm_is_vpn_gateway.site_a_s2s.public_ip_address,
    compute_private_ip = module.site_a_compute.compute_instance_ip,
    compute_public_ip  = ibm_is_floating_ip.site_a.address
  }
}

output "site_b_info" {
  value = {
    vpn_gateway_ip     = ibm_is_vpn_gateway.site_b_s2s.public_ip_address,
    compute_private_ip = module.site_b_compute.compute_instance_ip,
    compute_public_ip  = ibm_is_floating_ip.site_b.address
  }
}