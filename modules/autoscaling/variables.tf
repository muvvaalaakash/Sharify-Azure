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

variable "vmss_id" {
  description = "Target VMSS resource ID"
  type        = string
}

variable "autoscale_min" {
  description = "Minimum instances for autoscale"
  type        = number
  default     = 1
}

variable "autoscale_max" {
  description = "Maximum instances for autoscale"
  type        = number
  default     = 2
}

variable "autoscale_default" {
  description = "Default instances for autoscale"
  type        = number
  default     = 1
}
