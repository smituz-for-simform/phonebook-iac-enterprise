# VM

output "vm_id" {
  value = azurerm_linux_virtual_machine.frontend.id
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.frontend.name
}

output "vm_private_ip" {
  value = azurerm_network_interface.frontend.private_ip_address
}


# Public Access

output "public_ip" {
  value = azurerm_public_ip.frontend.ip_address
}

output "frontend_url" {
  value = "http://${azurerm_public_ip.frontend.ip_address}"
}


# Networking

output "nic_id" {
  value = azurerm_network_interface.frontend.id
}

output "nsg_id" {
  value = azurerm_network_security_group.frontend.id
}


# Future Automation

output "admin_username" {
  value = azurerm_linux_virtual_machine.frontend.admin_username
}