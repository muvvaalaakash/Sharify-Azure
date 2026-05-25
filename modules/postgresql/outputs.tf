output "server_id" {
  description = "PostgreSQL Flexible Server ID"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  description = "PostgreSQL Flexible Server FQDN"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_ids" {
  description = "Map of database names to database IDs"
  value       = { for k, db in azurerm_postgresql_flexible_server_database.this : k => db.id }
}
