output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = azurerm_nat_gateway.this.id
}

output "public_ip" {
  description = "NAT Gateway Public IP"
  value       = azurerm_public_ip.this.ip_address
}
