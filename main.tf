locals {
  list_of_subnets = split(";", data.external.subnet_rules.result.subnets)
  list_of_rules   = split(";", data.external.subnet_rules.result.rule_names)

  db_rules = null_resource.subnet_mappings.*.triggers

  vaultName = "infra-vault-${var.subscription}"
}

data "azurerm_key_vault" "infra_vault" {
  name                = local.vaultName
  resource_group_name = var.env == "prod" || var.env == "idam-prod" || var.env == "idam-prod2" ? "core-infra-prod" : "cnp-core-infra"
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
/*
resource "null_resource" "subnet_mappings" {
  for_each = local.list_of_subnets

  triggers = {
    rule_name = each.local.list_of_rules
    subnet_id = each.local.list_of_subnets
  }
}
*/
data "external" "subnet_rules" {
  program = ["python3", "${path.module}/find-subnets.py"]

  query = {
    env          = "${var.env}"
    product      = "${var.product}"
    github_token = "${data.azurerm_key_vault_secret.github_api_key.value}"
  }
}

resource "azurerm_resource_group" "data-resourcegroup" {
  name     = "${var.product}-data-${var.env}"
  location = var.location

  tags = merge(var.common_tags,
    map("lastUpdated", timestamp())
  )
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
}

resource "azurerm_postgresql_virtual_network_rule" "postgres-vnet-rule" {
  //for_each                             = toset(jsondecode(local.db_rules))
  for_each                             = toset([for r in local.db_rules: r.rule_name]) 
  name                                 = each.key
  //for_each                             = { for db_rule in (jsondecode(local.db_rules)) : db_rule.name => db_rule }
  //name                                 = each.value.rule_name
  resource_group_name                  = azurerm_resource_group.data-resourcegroup.name
  server_name                          = "${var.product}-${var.env}"
  subnet_id                            = each.value.subnet_id
  ignore_missing_vnet_service_endpoint = true
}