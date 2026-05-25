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
  description = "Delegated database subnet ID"
  type        = string
}

variable "vnet_id" {
  description = "VNET ID for Private DNS Zone link"
  type        = string
}

variable "db_sku" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms" # Burstable Standard B1ms
}

variable "admin_username" {
  description = "PostgreSQL Admin Username"
  type        = string
  default     = "Akash"
}

variable "admin_password" {
  description = "PostgreSQL Admin Password"
  type        = string
  sensitive   = true
}

variable "db_names" {
  description = "List of databases to create"
  type        = list(string)
  default     = ["users_db", "items_db", "inventory_db", "bookings_db", "payments_db", "reviews_db"]
}
