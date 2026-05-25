variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Frontend VMSS"
  type        = string
}

variable "vmss_sku" {
  description = "VM size for the VMSS"
  type        = string
  default     = "Standard_B2as_v2"
}

variable "vmss_instance_count" {
  description = "Number of instances in the VMSS"
  type        = number
  default     = 1
}

variable "admin_username" {
  description = "Admin username for the VMSS"
  type        = string
  default     = "Akash"
}

variable "admin_password" {
  description = "Admin password for the VMSS"
  type        = string
  sensitive   = true
}

variable "backend_address_pool_id" {
  description = "Application Gateway backend pool ID to associate with VMSS"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL to clone"
  type        = string
  default     = "https://github.com/muvvaalaakash/Shareify.git"
}
