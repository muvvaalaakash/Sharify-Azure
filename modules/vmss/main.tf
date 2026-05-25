resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                            = "${var.project_name}-frontend-vmss"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = var.vmss_sku
  instances                       = var.vmss_instance_count
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  zones = ["1"]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                         = "vmss-ipconfig"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = [var.backend_address_pool_id]
    }
  }

  custom_data = base64encode(file("${path.module}/scripts/frontend-bootstrap.sh"))
}
