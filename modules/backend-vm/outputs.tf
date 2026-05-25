output "vm_id" {
  description = "Backend VM ID"
  value       = azurerm_linux_virtual_machine.this.id
}

output "private_ip" {
  description = "Backend VM Private IP"
  value       = azurerm_network_interface.this.ip_configuration[0].private_ip_address
}
