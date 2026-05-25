variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "shareify"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet name to CIDR block mapping"
  type        = map(list(string))
  default = {
    appgw    = ["10.0.1.0/24"]
    frontend = ["10.0.2.0/24"]
    backend  = ["10.0.3.0/24"]
    database = ["10.0.4.0/24"]
    bastion  = ["10.0.5.0/26"]
  }
}

variable "vmss_sku" {
  description = "VM size for the frontend VMSS"
  type        = string
  default     = "Standard_Dc1ds_v3"
}

variable "vmss_instance_count" {
  description = "Initial instance count for frontend VMSS"
  type        = number
  default     = 1
}

variable "backend_vm_sku" {
  description = "VM size for the Backend VM"
  type        = string
  default     = "Standard_Dc1ds_v3"
}

variable "admin_username" {
  description = "Admin username for all VMs and databases"
  type        = string
  default     = "Akash"
}

variable "admin_password" {
  description = "Admin password for all VMs and databases"
  type        = string
  sensitive   = true
  default     = "Akash@21042004"
}

variable "postgresql_sku" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}
