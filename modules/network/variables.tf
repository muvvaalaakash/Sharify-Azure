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

variable "vnet_address_space" {
  description = "VNET address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Map of subnet name to address prefixes"
  type        = map(list(string))
  default = {
    appgw    = ["10.0.1.0/24"]
    frontend = ["10.0.2.0/24"]
    backend  = ["10.0.3.0/24"]
    database = ["10.0.4.0/24"]
    bastion  = ["10.0.5.0/26"]
  }
}
