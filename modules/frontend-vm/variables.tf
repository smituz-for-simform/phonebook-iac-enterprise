
# Resource Group

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}


# Networking

variable "frontend_subnet_id" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "nic_name" {
  type = string
}

variable "ip_configuration_name" {
  type = string
}

variable "nsg_name" {
  type = string
}


# VM

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}


# OS Disk

variable "os_disk_name" {
  type = string
}

variable "os_disk_size_gb" {
  type    = number
  default = 32
}


# Image

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts-gen2"
}

variable "image_version" {
  type    = string
  default = "latest"
}


# NSG Rules

variable "security_rules" {

  type = map(object({

    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string

    source_port_range          = string
    destination_port_range     = string

    source_address_prefix      = string
    destination_address_prefix = string
  }))
}