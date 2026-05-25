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
  description = "App Gateway Subnet ID"
  type        = string
}

variable "frontend_ip_addresses" {
  description = "List of frontend VMSS private IP addresses (if known, but since VMSS IPs are dynamic, we typically use the VMSS backend pool directly and associate it using VMSS configuration, or we can leave it empty and let VMSS associate itself to the pool)"
  type        = list(string)
  default     = []
}

variable "backend_vm_ip_address" {
  description = "Private IP address of the backend VM"
  type        = string
  default     = "10.0.3.4" # Default static private IP for backend VM
}
