locals {
  vaultName = var.key_vault_name != "" ? var.key_vault_name : "infra-vault-${var.subscription}"
  vault_resource_group_name = var.key_vault_rg != "" ? var.key_vault_rg : (
    local.is_prod ? "core-infra-prod" : "cnp-core-infra"
  )

  default_name = var.component != "" ? "${var.product}-${var.component}" : var.product
  name         = var.name != "" ? var.name : local.default_name
  server_name  = "${local.name}-${var.env}"
}

data "azurerm_key_vault" "infra_vault" {
  name                = local.vaultName
  resource_group_name = local.vault_resource_group_name
}

resource "azurerm_resource_group" "data-resourcegroup" {
  name     = "${local.name}-data-${var.env}"
  location = var.location

  tags = var.common_tags
}

resource "random_password" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  number  = true
}

resource "azurerm_postgresql_server" "postgres-paas" {
  name                = local.server_name
  location            = var.location
  resource_group_name = azurerm_resource_group.data-resourcegroup.name

  administrator_login          = var.postgresql_user
  administrator_login_password = random_password.password.result

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  backup_retention_days            = var.backup_retention_days
  geo_redundant_backup_enabled     = var.georedundant_backup
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  public_network_access_enabled    = var.subnet_id == "" ? true : false

  tags = var.common_tags
}

resource "azurerm_postgresql_database" "postgres-db" {
  name                = replace(var.database_name, "-", "")
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  server_name         = azurerm_postgresql_server.postgres-paas.name
  charset             = var.charset
  collation           = var.collation
}

locals {
  is_prod     = length(regexall(".*(prod).*", var.env)) > 0
  admin_group = local.is_prod ? "DTS Platform Operations SC" : "DTS Platform Operations"
  # psql needs spaces escaped in user names
  escaped_admin_group = replace(local.admin_group, " ", "\\ ")
}

data "azurerm_client_config" "current" {}

data "azuread_group" "db_admin" {
  display_name     = local.admin_group
  security_enabled = true
}

resource "azurerm_postgresql_active_directory_administrator" "admin" {
  server_name         = azurerm_postgresql_database.postgres-db.server_name
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  login               = local.admin_group
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id
}
