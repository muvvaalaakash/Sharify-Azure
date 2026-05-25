# ══════════════════════════════════════════════════════════════
# TERRAFORM + PROVIDER
# ══════════════════════════════════════════════════════════════
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# ══════════════════════════════════════════════════════════════
# MODULE 1: RESOURCE GROUP
# ══════════════════════════════════════════════════════════════
module "resource_group" {
  source = "./modules/resource-group"

  name     = "${var.project_name}-rg"
  location = var.location
}

# ══════════════════════════════════════════════════════════════
# MODULE 2: NETWORK
# ══════════════════════════════════════════════════════════════
module "network" {
  source = "./modules/network"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  project_name        = var.project_name
  vnet_address_space  = var.vnet_address_space
  subnet_prefixes     = var.subnet_prefixes
}

# ══════════════════════════════════════════════════════════════
# MODULE 3: NAT GATEWAY
# ══════════════════════════════════════════════════════════════
module "nat_gateway" {
  source = "./modules/nat-gateway"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  project_name        = var.project_name
  subnet_ids = [
    module.network.subnet_ids["frontend"],
    module.network.subnet_ids["backend"]
  ]
}

# ══════════════════════════════════════════════════════════════
# MODULE 7: POSTGRESQL (Flex Server & Databases)
# ══════════════════════════════════════════════════════════════
# Wires before Backend VM because VMSS/VM bootstraps depend on it
module "postgresql" {
  source = "./modules/postgresql"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  project_name        = var.project_name
  subnet_id           = module.network.subnet_ids["database"]
  vnet_id             = module.network.vnet_id
  db_sku              = var.postgresql_sku
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}

# ══════════════════════════════════════════════════════════════
# MODULE 4: APPLICATION GATEWAY + WAF
# ══════════════════════════════════════════════════════════════
module "application_gateway" {
  source = "./modules/application-gateway"

  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  project_name          = var.project_name
  subnet_id             = module.network.subnet_ids["appgw"]
  backend_vm_ip_address = "10.0.3.4"
}

# ══════════════════════════════════════════════════════════════
# MODULE 5: VMSS (Frontend)
# ══════════════════════════════════════════════════════════════
module "vmss" {
  source = "./modules/vmss"

  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  project_name            = var.project_name
  subnet_id               = module.network.subnet_ids["frontend"]
  vmss_sku                = var.vmss_sku
  vmss_instance_count     = var.vmss_instance_count
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  backend_address_pool_id = module.application_gateway.frontend_backend_pool_id

  depends_on = [module.application_gateway]
}

# ══════════════════════════════════════════════════════════════
# MODULE 6: BACKEND VM
# ══════════════════════════════════════════════════════════════
module "backend_vm" {
  source = "./modules/backend-vm"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  project_name        = var.project_name
  subnet_id           = module.network.subnet_ids["backend"]
  vm_sku              = var.backend_vm_sku
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  db_host             = module.postgresql.fqdn
  db_user             = var.admin_username
  db_password         = var.admin_password
  private_ip_address  = "10.0.3.4"

  depends_on = [module.postgresql]
}

# ══════════════════════════════════════════════════════════════
# MODULE 8: BASTION
# ══════════════════════════════════════════════════════════════
module "bastion" {
  source = "./modules/bastion"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  project_name        = var.project_name
  subnet_id           = module.network.subnet_ids["bastion"]
}

# ══════════════════════════════════════════════════════════════
# MODULE 9: AUTOSCALING
# ══════════════════════════════════════════════════════════════
module "autoscaling" {
  source = "./modules/autoscaling"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  project_name        = var.project_name
  vmss_id             = module.vmss.vmss_id
}
