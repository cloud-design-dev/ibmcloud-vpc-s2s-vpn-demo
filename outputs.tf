output "vpn_info" {
  value = ibm_is_vpn_gateway.site_a_s2s
}

output "vpn_gateway_ip" {
  value = ibm_is_vpn_gateway.site_a_s2s.public_ip_address
}