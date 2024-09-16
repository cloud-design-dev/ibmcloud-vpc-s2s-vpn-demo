variable "ibmcloud_api_key" {
  description = "The IBM Cloud API key to use for provisioning resources"
  type        = string
  sensitive   = true
}

variable "project_prefix" {
  description = "The prefix to use for naming resources. If none is provided, a random string will be generated."
  type        = string
  default     = ""
}

variable "ibmcloud_region" {
  description = "The IBM Cloud region to use for provisioning VPCs and other resources."
  type        = string
}

variable "existing_resource_group" {
  description = "The IBM Cloud resource group to assign to the provisioned resources."
  type        = string
}

# variable "existing_ssh_key" {
#   description = "The name of an existing SSH key to use for provisioning resources. If one is not provided, a new key will be generated."
#   type        = string
#   default     = ""
# }