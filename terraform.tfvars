project_name       = "shareify"
location           = "Central India"
vnet_address_space = ["10.0.0.0/16"]
subnet_prefixes = {
  appgw    = ["10.0.1.0/24"]
  frontend = ["10.0.2.0/24"]
  backend  = ["10.0.3.0/24"]
  database = ["10.0.4.0/24"]
  bastion  = ["10.0.5.0/26"]
}
vmss_sku            = "Standard_B2as_v2"
vmss_instance_count = 1
backend_vm_sku      = "Standard_B2as_v2"
admin_username      = "Akash"
admin_password      = "Akash@21042004"
postgresql_sku      = "GP_Standard_D2s_v3"
