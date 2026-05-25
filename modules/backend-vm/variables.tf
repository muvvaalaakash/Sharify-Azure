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
  description = "Subnet ID for Backend VM"
  type        = string
}

variable "vm_sku" {
  description = "VM size for the Backend VM"
  type        = string
  default     = "Standard_Dc1ds_v3"
}

variable "admin_username" {
  description = "Admin username for the Backend VM"
  type        = string
  default     = "Akash"
}

variable "admin_password" {
  description = "Admin password for the Backend VM"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "PostgreSQL Flexible Server FQDN"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL Admin Username"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL Admin Password"
  type        = string
  sensitive   = true
}

variable "private_ip_address" {
  description = "Private IP address of the Backend VM"
  type        = string
  default     = "10.0.3.4"
}
