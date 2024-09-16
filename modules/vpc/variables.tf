variable "name" {}
variable "resource_group_id" {}
variable "tags" {}
variable "ibmcloud_region" {}
variable "classic_access" {
  description = "Whether to enable classic access for the VPC"
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The default address prefix to use for the VPC"
  type        = string
  default     = "manual"
}

variable "site_address_prefix" {}