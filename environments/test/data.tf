data "azurerm_key_vault" "kv" {
  name                = "kv-phonebook-secrets"
  resource_group_name = "rg-terraform-assets"
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-pub-key"
  key_vault_id = data.azurerm_key_vault.kv.id
}