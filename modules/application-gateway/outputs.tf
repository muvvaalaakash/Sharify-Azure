output "app_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}

output "public_ip" {
  description = "Application Gateway Public IP"
  value       = azurerm_public_ip.this.ip_address
}

output "frontend_backend_pool_id" {
  description = "ID of the frontend backend address pool for VMSS association"
  value       = one([for pool in azurerm_application_gateway.this.backend_address_pool : pool.id if pool.name == "frontend-pool"])
}
