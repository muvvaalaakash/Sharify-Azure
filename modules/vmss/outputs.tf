output "vmss_id" {
  description = "Virtual Machine Scale Set ID"
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "vmss_name" {
  description = "Virtual Machine Scale Set Name"
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}
