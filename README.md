# Overview

Deploy 2 VPCs and connect them with Site to Site gateways using policy based VPN.

## Getting started

### Clone repository and configure terraform variables

The first step is to clone the repository and configure the terraform variables.

```shell
git clone https://github.com/cloud-design-dev/ibmcloud-vpc-ts-router.git
cd ibmcloud-vpc-ts-router
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

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.69.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | 1.69.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_add_rules_to_default_vpc_security_group"></a> [add\_rules\_to\_default\_vpc\_security\_group](#module\_add\_rules\_to\_default\_vpc\_security\_group) | terraform-ibm-modules/security-group/ibm | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.5 |
| <a name="module_site_a_vpc"></a> [site\_a\_vpc](#module\_site\_a\_vpc) | ./modules/vpc | n/a |
| <a name="module_site_b_vpc"></a> [site\_b\_vpc](#module\_site\_b\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_is_vpn_gateway.site_a_s2s](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.2/docs/resources/is_vpn_gateway) | resource |
| [ibm_is_vpn_gateway.site_b_s2s](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.2/docs/resources/is_vpn_gateway) | resource |
| [ibm_is_vpn_gateway_connection.site_a_connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.2/docs/resources/is_vpn_gateway_connection) | resource |
| [ibm_is_vpn_gateway_connection.site_b_connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.2/docs/resources/is_vpn_gateway_connection) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_preshared_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [ibm_is_zones.regional](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.2/docs/data-sources/is_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | The IBM Cloud resource group to assign to the provisioned resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key to use for provisioning resources | `string` | n/a | yes |
| <a name="input_ibmcloud_region"></a> [ibmcloud\_region](#input\_ibmcloud\_region) | The IBM Cloud region to use for provisioning VPCs and other resources. | `string` | n/a | yes |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | The prefix to use for naming resources. If none is provided, a random string will be generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_gateway_ip"></a> [vpn\_gateway\_ip](#output\_vpn\_gateway\_ip) | n/a |
| <a name="output_vpn_info"></a> [vpn\_info](#output\_vpn\_info) | n/a |
<!-- END_TF_DOCS -->