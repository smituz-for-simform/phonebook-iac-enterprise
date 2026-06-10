terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }

    # required_providers{
    #   docker = ""
    # }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-assets"
    storage_account_name = "saremotestatesmit"
    container_name       = "phonebook-terraform-state-2"
    key                  = "dev.tfstate"
  }

  required_version = ">=1.15"
}

provider "azurerm" {
  features {}
}