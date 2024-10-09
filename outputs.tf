output "Site_A_Information" {
  value = [
    "VPN Gateway IP: ${ibm_is_vpn_gateway.site_a_s2s.public_ip_address}",
    "Compute Private IP: ${module.site_a_compute.compute_instance_ip}",
    "VPC URL: https://cloud.ibm.com/infrastructure/network/vpc/${var.ibmcloud_region}~${module.site_a_vpc.vpc_id}/overview",
    "VPN URL: https://cloud.ibm.com/infrastructure/network/vpngateway/${var.ibmcloud_region}~${ibm_is_vpn_gateway.site_a_s2s.id}/overview"
  ]
}


output "Site_B_Information" {
  value = [
    "VPN Gateway IP: ${ibm_is_vpn_gateway.site_b_s2s.public_ip_address}",
    "Compute Private IP: ${module.site_b_compute.compute_instance_ip}",
    "VPC URL: https://cloud.ibm.com/infrastructure/network/vpc/${var.ibmcloud_region}~${module.site_b_vpc.vpc_id}/overview",
    "VPN URL: https://cloud.ibm.com/infrastructure/network/vpngateway/${var.ibmcloud_region}~${ibm_is_vpn_gateway.site_b_s2s.id}/overview"
  ]
}

