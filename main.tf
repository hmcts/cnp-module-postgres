locals {
  list_of_subnets = split(";", data.external.subnet_rules.result.subnets)
  list_of_rules   = split(";", data.external.subnet_rules.result.rule_names)

  db_rules = null_resource.subnet_mappings.*.triggers

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
    env              = var.env
    product          = var.product
    github_token     = data.azurerm_key_vault_secret.github_api_key.value
    subnets_filename = var.subnets_filename
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

data "template_file" "postgrestemplate" {
  template = file("${path.module}/templates/postgres-paas.json")
}

resource "azurerm_template_deployment" "postgres-paas" {
  template_body       = data.template_file.postgrestemplate.rendered
  name                = local.server_name
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  deployment_mode     = "Incremental"

  parameters = {
    administratorLogin         = var.postgresql_user
    administratorLoginPassword = random_string.password.result
    location                   = var.location
    env                        = var.env
    serverName                 = local.server_name
    dbName                     = replace(var.database_name, "-", "")
    skuName                    = var.sku_name
    skuCapacity                = var.sku_capacity
    skuTier                    = var.sku_tier
    version                    = var.postgresql_version
    skuSizeMB                  = var.storage_mb
    sslEnforcement             = var.ssl_enforcement
    backupRetentionDays        = var.backup_retention_days
    geoRedundantBackup         = var.georedundant_backup
    charset                    = var.charset
    collation                  = var.collation
    dbRules                    = base64encode(jsonencode(local.db_rules))
    commonTags                 = base64encode(jsonencode(var.common_tags))
  }
}

resource "azurerm_postgresql_database" "additional_databases" {
  for_each = toset(var.additional_databases)

  name                = replace("${each.key}", "-", "")
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  server_name         = local.server_name
  charset             = var.charset
  collation           = var.collation

  depends_on = [
    azurerm_template_deployment.postgres-paas
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
  display_name     = local.admin_group
  security_enabled = true
}

resource "azurerm_postgresql_active_directory_administrator" "admin" {
  server_name         = local.server_name
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  login               = local.admin_group
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id

  depends_on = [
    azurerm_template_deployment.postgres-paas
  ]
}
