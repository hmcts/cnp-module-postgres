locals {
  list_of_subnets = "${split(";", data.external.subnet_rules.result.subnets)}"
  list_of_rules   = "${split(";", data.external.subnet_rules.result.rule_names)}"

  db_rules = "${null_resource.subnet_mappings.*.triggers}"

  vaultName = "dtssharedservicessboxkv" #"infra-vault-${var.subscription}"
}

data "azurerm_key_vault" "infra_vault" {
  name                = "${local.vaultName}"
  resource_group_name = "genesis-rg" #"${var.env == "prod" || var.env == "idam-prod" || var.env == "idam-prod2" ? "core-infra-prod" : "cnp-core-infra"}"
}

data "azurerm_key_vault_secret" "github_api_key" {
  name         = "hmcts-github-apikey"
  key_vault_id = "${data.azurerm_key_vault.infra_vault.id}"
}

# https://gist.github.com/brikis98/f3fe2ae06f996b40b55eebcb74ed9a9e
resource "null_resource" "subnet_mappings" {
  count = "${length(local.list_of_subnets)}"

  triggers = {
    rule_name = "${element(local.list_of_rules, count.index)}"
    subnet_id = "${element(local.list_of_subnets, count.index)}"
  }
}

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
  location = "${var.location}"

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
  template = "${file("${path.module}/templates/postgres-paas.json")}"
}

resource "azurerm_template_deployment" "postgres-paas" {
  template_body       = "${data.template_file.postgrestemplate.rendered}"
  name                = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.data-resourcegroup.name}"
  deployment_mode     = "Incremental"

  parameters = {
    administratorLogin         = "${var.postgresql_user}"
    administratorLoginPassword = "${random_string.password.result}"
    location                   = "${var.location}"
    env                        = "${var.env}"
    serverName                 = "${var.product}-${var.env}"
    dbName                     = "${replace(var.database_name, "-", "")}"
    skuName                    = "${var.sku_name}"
    skuCapacity                = "${var.sku_capacity}"
    skuTier                    = "${var.sku_tier}"
    version                    = "${var.postgresql_version}"
    skuSizeMB                  = "${var.storage_mb}"
    sslEnforcement             = "${var.ssl_enforcement}"
    backupRetentionDays        = "${var.backup_retention_days}"
    geoRedundantBackup         = "${var.georedundant_backup}"
    charset                    = "${var.charset}"
    collation                  = "${var.collation}"
    dbRules                    = "${base64encode(jsonencode(local.db_rules))}"
    commonTags                 = "${base64encode(jsonencode(var.common_tags))}"
  }
}

locals {
  is_prod     = length(regexall(".*(prod).*", var.env)) > 0
  admin_group = local.is_prod ? "DTS Platform Operations SC" : "DTS Platform Operations"
}

data "azurerm_client_config" "current" {}

data "azuread_group" "db_admin" {
  name = local.admin_group
}

resource "azurerm_postgresql_active_directory_administrator" "admin" {
  server_name         = "${var.product}-${var.env}"
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  login               = local.admin_group
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id

  depends_on = [
    azurerm_template_deployment.postgres-paas
  ]
}
