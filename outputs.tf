output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.application_gateway.public_ip
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = module.bastion.public_ip
}

output "postgresql_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = module.postgresql.fqdn
}

output "backend_vm_private_ip" {
  description = "Private IP of the Backend VM"
  value       = module.backend_vm.private_ip
}

output "vmss_name" {
  description = "Name of the Frontend VMSS"
  value       = module.vmss.vmss_name
}
