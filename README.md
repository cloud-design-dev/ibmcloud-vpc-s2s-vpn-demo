# Overview

Deploy 2 VPCs and connect them with Site to Site gateways using policy based VPN.

## Getting started

### Clone repository and configure terraform variables

The first step is to clone the repository and configure the terraform variables.

```shell
git clone https://github.com/cloud-design-dev/ibmcloud-vpc-s2s-vpn-demo.git
cd ibmcloud-vpc-s2s-vpn-demo
```

Copy the example terraform variables file and update the values with your own. See [inputs](#inputs) for more information on the required variables.

```shell
cp tfvars-template terraform.tfvars
```

### Initialize, Plan and Apply the Terraform configuration

Once you have the required variables set, you can initialize the terraform configuration and create a plan for the deployment.

```shell
terraform init
terraform plan -out=plan.out
```

If no errors are returned, you can apply the plan to create the VPCs, subnets, and compute instances.

```shell
terraform apply plan.out
```

When the provosion is complete, you should see the output of the plan, including the VPN gateway IPs.

```shell
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

Site_A_Information = [
  "VPN Gateway IP: 169.63.99.32",
  "Compute Private IP: 172.16.0.20",
  "Compute Public IP: 150.239.113.167",
  "VPC URL: https://cloud.ibm.com/infrastructure/network/vpc/us-east~r014-78c1dc0f-f20e-43af-a8a4-0909a8a5d7a7/overview",
  "VPN URL: https://cloud.ibm.com/infrastructure/network/vpngateway/us-east~0757-55e495cb-aee1-4a86-ba31-700386b065a9/overview",
]
Site_B_Information = [
  "VPN Gateway IP: 52.116.123.171",
  "Compute Private IP: 192.168.0.20",
  "Compute Public IP: 52.116.120.122",
  "VPC URL: https://cloud.ibm.com/infrastructure/network/vpc/us-east~r014-e629ce5e-4c32-42ea-b0e8-806887969e38/overview",
  "VPN URL: https://cloud.ibm.com/infrastructure/network/vpngateway/us-east~0757-bdee8a6c-fada-4a86-824e-9c94e7fbc9f3/overview",
]
```

### Test Connnectivity

We can quickly test the connection by pinging from site a compute to site b compute and vice versa. 

```shell
ssh -t root@150.239.113.167 'ping -c3 192.168.0.20'
PING 192.168.0.20 (192.168.0.20) 56(84) bytes of data.
64 bytes from 192.168.0.20: icmp_seq=1 ttl=62 time=1.51 ms
64 bytes from 192.168.0.20: icmp_seq=2 ttl=62 time=1.78 ms
64 bytes from 192.168.0.20: icmp_seq=3 ttl=62 time=1.58 ms

--- 192.168.0.20 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 1.508/1.623/1.779/0.114 ms
Connection to 150.239.113.167 closed.

ssh -t root@52.116.120.122 'ping -c3 172.16.0.20'
PING 172.16.0.20 (172.16.0.20) 56(84) bytes of data.
64 bytes from 172.16.0.20: icmp_seq=1 ttl=62 time=1.78 ms
64 bytes from 172.16.0.20: icmp_seq=2 ttl=62 time=1.75 ms
64 bytes from 172.16.0.20: icmp_seq=3 ttl=62 time=1.73 ms

--- 172.16.0.20 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 1.726/1.751/1.780/0.022 ms
Connection to 52.116.120.122 closed.
```
