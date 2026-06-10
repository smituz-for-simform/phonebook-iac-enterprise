resource "azurerm_public_ip" "frontend" {

  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
}

resource "azurerm_network_interface" "frontend" {

  name                = var.nic_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {

    name = var.ip_configuration_name

    subnet_id = var.frontend_subnet_id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.frontend.id
  }
}

resource "azurerm_network_security_group" "frontend" {

  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {

    for_each = var.security_rules

    content {

      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_interface_security_group_association" "frontend" {

  network_interface_id      = azurerm_network_interface.frontend.id

  network_security_group_id = azurerm_network_security_group.frontend.id
}

resource "azurerm_linux_virtual_machine" "frontend" {

  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location

  size = var.vm_size

  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.frontend.id
  ]

  admin_ssh_key {

    username   = var.admin_username

    public_key = var.ssh_public_key
  }

  os_disk {

    name = var.os_disk_name

    storage_account_type = "Standard_LRS"

    caching = "ReadWrite"

    disk_size_gb = var.os_disk_size_gb
  }

  source_image_reference {

    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}