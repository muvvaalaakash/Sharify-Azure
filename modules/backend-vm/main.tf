resource "azurerm_network_interface" "this" {
  name                = "${var.project_name}-backend-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "${var.project_name}-backend-vm"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_sku
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.this.id]

  zone = "1"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/backend-bootstrap.sh", {
    db_host     = var.db_host
    db_user     = var.db_user
    db_password = var.db_password
  }))
}
