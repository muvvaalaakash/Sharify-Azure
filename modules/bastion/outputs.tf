output "bastion_id" {
  description = "Bastion Host ID"
  value       = azurerm_bastion_host.this.id
}

output "public_ip" {
  description = "Bastion Public IP"
  value       = azurerm_public_ip.this.ip_address
}
