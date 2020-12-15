data "azurerm_key_vault_secret" "db_manager_username" {
  key_vault_id = data.azurerm_key_vault.infra_vault.id
  name         = "db-manager-username"
}

data "azurerm_key_vault_secret" "db_manager_password" {
  key_vault_id = data.azurerm_key_vault.infra_vault.id
  name         = "db-manager-password"
}
