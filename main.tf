locals {
  jenkins_subscription_id = "${(var.env == "sandbox" || var.env == "saat" || var.env == "sprod" || var.env == "idam-sandbox" || var.env == "idam-saat" || var.env == "idam-sprod") ? "${data.azurerm_key_vault_secret.DCD-CFT-Sandbox-subscription-id.value}" : "${data.azurerm_key_vault_secret.DCD-CNP-Prod-subscription-id.value}"}"
  jenkins_rg              = "${(var.env == "sandbox" || var.env == "saat" || var.env == "sprod" || var.env == "idam-sandbox" || var.env == "idam-saat" || var.env == "idam-sprod") ? "mgmt-infra-sandbox" : "mgmt-infra-prod"}"
  jenkins_vnet            = "${(var.env == "sandbox" || var.env == "saat" || var.env == "sprod" || var.env == "idam-sandbox" || var.env == "idam-saat" || var.env == "idam-sprod") ? "mgmt-infra-sandbox" : "mgmt-infra-prod"}"
  bastion_subscription_id = "${(var.env == "prod" || var.env == "aat") ? "${data.azurerm_key_vault_secret.Reform-CFT-Prod-subscription-id.value}" : "${data.azurerm_key_vault_secret.Reform-CFT-Mgmt-subscription-id.value}"}"
  bastion_rg              = "${(var.env == "prod") ? (var.env == "aat" ) ? "betaProdCoreRG" : "betaPreProdCoreRG" : "reformMgmtCoreRG"}"
  bastion_vnet            = "${(var.env == "prod") ? (var.env == "aat" ) ? "betaProdVNet" : "betaPreProdVNet" : "reformMgmtCoreVNet"}"
  bastion_subnet_name     = "${(var.env == "prod") ? (var.env == "aat" ) ? "betaProdDataSN" : "betaPreProdDataSN" : "reformMgmtDmzSN"}"
  vaultname               = "${(var.env == "prod") ? (var.env == "aat" || var.env == "demo" || var.env == "preview") ? (var.env == "hmcts-demo") ? "infra-vault-prod" : "infra-vault-nonprod" : "infra-vault-hmctsdemo" : "infra-vault-sandbox"}"
  ase_subnet_id           = "${data.azurerm_subnet.ase.id}"
  asev2_subnet_id         = "${element(concat(data.azurerm_subnet.asev2.*.id, list("")), 0)}"
  idam_api_subnet_id      = "${element(concat(data.azurerm_subnet.idam_api.*.id, list("")), 0)}"
  idam_idm_subnet_id      = "${element(concat(data.azurerm_subnet.idam_idm.*.id, list("")), 0)}"
  idam_jumpbox_subnet_id  = "${element(concat(data.azurerm_subnet.idam_jumpbox.*.id, list("")), 0)}"
  jenkins_subnet_id       = "/subscriptions/${local.jenkins_subscription_id}/resourceGroups/${local.jenkins_rg}/providers/Microsoft.Network/virtualNetworks/${local.jenkins_vnet}/subnets/${var.jenkins_subnet_name}"
  bastion_subnet_id       = "/subscriptions/${local.bastion_subscription_id}/resourceGroups/${local.bastion_rg}/providers/Microsoft.Network/virtualNetworks/${local.bastion_vnet}/subnets/${local.bastion_subnet_name}"

  ase_vnet_rule_name          = "${var.env}ASEVNET"
  asev2_vnet_rule_name        = "${var.env}ASEv2VNET"
  idam_api_vnet_rule_name     = "${var.env}IdamAPIVNET"
  idam_idm_vnet_rule_name     = "${var.env}IdamIdmVNET"
  idam_jumpbox_vnet_rule_name = "${var.env}IdamJumpbox"
  bastion_vnet_rule_name      = "${var.env}BastionVNET"
  jenkins_vnet_rule_name      = "${var.env}JenkinsVNET"
}

resource "azurerm_resource_group" "data-resourcegroup" {
  name     = "${var.product}-data-${var.env}"
  location = "${var.location}"

  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
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

data "azurerm_subnet" "ase" {
  name                 = "core-infra-subnet-3-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
}

data "azurerm_subnet" "asev2" {
  count                = "${var.is_asev2_present == "true" ? 1 : 0}"
  name                 = "core-infra-subnet-ase-${var.env}v2"
  virtual_network_name = "core-infra-vnet-${var.env}v2"
  resource_group_name  = "core-infra-${var.env}v2"
}

data "azurerm_subnet" "idam_api" {
  count                = "${var.is_idam_api == "true" ? 1 : 0}"
  name                 = "core-infra-subnet-2-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
}

data "azurerm_subnet" "idam_idm" {
  count                = "${var.is_idam_idm == "true" ? 1 : 0}"
  name                 = "core-infra-subnet-4-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
}

data "azurerm_subnet" "idam_jumpbox" {
  count                = "${var.idam_jumpbox == "true" ? 1 : 0}"
  name                 = "core-infra-subnet-15-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
}

data "azurerm_key_vault_secret" "DCD-CNP-Prod-subscription-id" {
  name      = "DCD-CNP-Prod-subscription-id"
  vault_uri = "https://${local.vaultname}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "DCD-CFT-Sandbox-subscription-id" {
  name      = "DCD-CFT-Sandbox-subscription-id"
  vault_uri = "https://${local.vaultname}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "Reform-CFT-Prod-subscription-id" {
  name      = "Reform-CFT-Prod-subscription-id"
  vault_uri = "https://${local.vaultname}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "Reform-CFT-Mgmt-subscription-id" {
  name      = "Reform-CFT-Mgmt-subscription-id"
  vault_uri = "https://${local.vaultname}.vault.azure.net/"
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
    skuTier                    = "${var.sku_tier}"
    version                    = "${var.postgresql_version}"
    skuSizeMB                  = "${var.storage_mb}"
    sslEnforcement             = "${var.ssl_enforcement}"
    backupRetentionDays        = "${var.backup_retention_days}"
    geoRedundantBackup         = "${var.georedundant_backup}"
    charset                    = "${var.charset}"
    collation                  = "${var.collation}.${var.charset}"
    AseVnetRuleName            = "${local.ase_vnet_rule_name}"
    AseSubnetId                = "${local.ase_subnet_id}"
    Asev2VnetRuleName          = "${local.asev2_vnet_rule_name}"
    Asev2SubnetId              = "${local.asev2_subnet_id}"
    isAseV2Present             = "${var.is_asev2_present}"
    IdamAPIVnetRuleName        = "${local.idam_api_vnet_rule_name}"
    IdamAPISubnetId            = "${local.idam_api_subnet_id}"
    isIdamAPI                  = "${var.is_idam_api}"
    IdamIdmVnetRuleName        = "${local.idam_idm_vnet_rule_name}"
    IdamIdmSubnetId            = "${local.idam_idm_subnet_id}"
    isIdamIdm                  = "${var.is_idam_idm}"
    IdamJumpboxVnetRuleName    = "${local.idam_jumpbox_vnet_rule_name}"
    IdamJumpboxSubnetId        = "${local.idam_jumpbox_subnet_id}"
    IdamJumpbox                = "${var.idam_jumpbox}"
    BastionVnetRuleName        = "${local.bastion_vnet_rule_name}"
    BastionSubnetId            = "${local.bastion_subnet_id}"
    JenkinsVnetRuleName        = "${local.jenkins_vnet_rule_name}"
    JenkinsSubnetId            = "${local.jenkins_subnet_id}"
  }
}
