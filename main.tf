provider "azurerm" {
  alias = "mgmt"
}

locals {
  ase_subnet_id          = "${data.azurerm_key_vault_secret.ase_subnet_id.value}"
  jenkins_subnet_id      = "${data.azurerm_key_vault_secret.jenkins_subnet_id.value}"
  bastion_subnet_id      = "${data.azurerm_key_vault_secret.bastion_subnet_id.value}"
  ase_vnet_rule_name     = "${var.env}ASEVNET"
  bastion_vnet_rule_name = "${var.env}BastionVNET"
  jenkins_vnet_rule_name = "${var.env}JenkinsVNET"
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

data "azurerm_key_vault_secret" "jenkins_subnet_id" {
  name      = "jenkins-subnet-id"
  vault_uri = "https://infra-vault-${var.subscription}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "ase_subnet_id" {
  name      = "ase-${var.env}-subnet-id"
  vault_uri = "https://infra-vault-${var.subscription}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "bastion_subnet_id" {
  name      = "bastion-subnet-id"
  vault_uri = "https://infra-vault-${var.subscription}.vault.azure.net/"
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
    subscription               = "${var.subscription}"
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
    BastionVnetRuleName        = "${local.bastion_vnet_rule_name}"
    BastionSubnetId            = "${local.bastion_subnet_id}"
    JenkinsVnetRuleName        = "${local.jenkins_vnet_rule_name}"
    JenkinsSubnetId            = "${local.jenkins_subnet_id}"
  }
}
