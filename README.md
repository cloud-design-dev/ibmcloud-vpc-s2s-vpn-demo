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

#### Variables 

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | The IBM Cloud resource group to assign to the provisioned resources. | `string` | n/a | yes |
| <a name="input_existing_ssh_key"></a> [existing\_ssh\_key](#input\_existing\_ssh\_key) | The name of an existing SSH key to use for provisioning resources. If one is not provided, a new key will be generated. | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key to use for provisioning resources | `string` | n/a | yes |
| <a name="input_ibmcloud_region"></a> [ibmcloud\_region](#input\_ibmcloud\_region) | The IBM Cloud region to use for provisioning VPCs and other resources. | `string` | n/a | yes |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | The prefix to use for naming resources. If none is provided, a random string will be generated. | `string` | `""` | no |


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
Apply complete! Resources: 33 added, 0 changed, 0 destroyed.

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

You can test the connectivity between the two VPCs by SSHing into the compute instances and pinging across the VPN tunnel.

```shell
site_a_private_ip=$(terraform output -json site_a_info | jq -r '.compute_private_ip')
site_b_private_ip=$(terraform output -json site_b_info | jq -r '.compute_private_ip')
site_a_public_ip=$(terraform output -json site_a_info | jq -r '.compute_public_ip')
site_b_public_ip=$(terraform output -json site_b_info | jq -r '.compute_public_ip')


ssh -t "root@${site_a_public_ip}" "ping -c3 ${site_b_private_ip}"
ssh -t "root@${site_b_public_ip}" "ping -c3 ${site_a_private_ip}"
```

The code also includes an ansible playbook you can use to ping across the VPN tunnel. 

```shell
ansible-playbook -i ansible/inventory.ini ansible/ping.yaml
```

![Ansible playbook output](https://images.gh40-dev.systems/Shared-Image-2024-10-10-12-43-01.png)