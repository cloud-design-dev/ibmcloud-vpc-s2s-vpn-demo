output "site_a_gateway_ip" {
  value = ibm_is_vpn_gateway.site_a_s2s.public_ip_address
}

output "site_2_gateway_ip" {
  value = ibm_is_vpn_gateway.site_a_s2s.public_ip_address
}