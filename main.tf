locals {
  list_of_subnets = split(";", data.external.subnet_rules.result.subnets)
  list_of_rules   = split(";", data.external.subnet_rules.result.rule_names)

  db_rules = null_resource.subnet_mappings.*.triggers

  vaultName = var.key_vault_name != "" ? var.key_vault_name : "infra-vault-${var.subscription}"
  vault_resource_group_name = var.key_vault_rg != "" ? var.key_vault_rg : (
    local.is_prod ? "core-infra-prod" : "cnp-core-infra"
  )

  default_name = var.component != "" ? "${var.product}-${var.component}" : var.product
  name = var.name != "" ? var.name : local.default_name
  server_name = "${local.name}-${var.env}"
}

data "azurerm_key_vault" "infra_vault" {
  name                = local.vaultName
  resource_group_name = local.vault_resource_group_name
}

data "azurerm_key_vault_secret" "github_api_key" {
  name         = "hmcts-github-apikey"
  key_vault_id = data.azurerm_key_vault.infra_vault.id
}

# https://gist.github.com/brikis98/f3fe2ae06f996b40b55eebcb74ed9a9e
resource "null_resource" "subnet_mappings" {
  count = length(local.list_of_subnets)

  triggers = {
    rule_name = element(local.list_of_rules, count.index)
    subnet_id = element(local.list_of_subnets, count.index)
  }
}

data "external" "subnet_rules" {
  program = ["python3", "${path.module}/find-subnets.py"]

  query = {
    env              = "${var.env}"
    product          = "${var.product}"
    github_token     = "${data.azurerm_key_vault_secret.github_api_key.value}"
    subnets_filename = "${var.subnets_filename}"
  }
}

resource "azurerm_resource_group" "data-resourcegroup" {
  name     = "${local.name}-data-${var.env}"
  location = var.location

  tags = var.common_tags
}

resource "random_string" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  number  = true
}

resource "azurerm_postgresql_server" "postgres-paas" {
  name                = "${var.product}-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.data-resourcegroup.name

  administrator_login          = var.postgresql_user
  administrator_login_password = random_string.password.result

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.georedundant_backup

  ssl_enforcement_enabled = var.ssl_enforcement

  tags = var.common_tags
}

resource "azurerm_postgresql_database" "postgres-db" {
  name                = replace(var.database_name, "-", "")
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  server_name         = "${var.product}-${var.env}"
  charset             = var.charset
  collation           = var.collation

  depends_on = [
    azurerm_postgresql_server.postgres-paas
  ]
}

resource "azurerm_postgresql_virtual_network_rule" "postgres-vnet-rule" {
  for_each                             = { for db_rule in local.db_rules : db_rule.rule_name => db_rule }
  name                                 = each.value.rule_name
  resource_group_name                  = azurerm_resource_group.data-resourcegroup.name
  server_name                          = local.server_name
  subnet_id                            = each.value.subnet_id
  ignore_missing_vnet_service_endpoint = true

  depends_on = [
    azurerm_postgresql_database.postgres-db
]
}


locals {
  is_prod     = length(regexall(".*(prod).*", var.env)) > 0
  admin_group = local.is_prod ? "DTS Platform Operations SC" : "DTS Platform Operations"
  # psql needs spaces escaped in user names
  escaped_admin_group = replace(local.admin_group, " ", "\\ ")
}

data "azurerm_client_config" "current" {}

data "azuread_group" "db_admin" {
  name = local.admin_group
}

resource "azurerm_postgresql_active_directory_administrator" "admin" {
  server_name         = azurerm_postgresql_database.postgres-db.server_name
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  login               = local.admin_group
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id
}
