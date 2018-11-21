provider "azurerm" {
  alias = "mgmt"
}

locals {
  jenkins_subscription_id = "${(var.env == "prod" || var.env == "aat" || var.env == "hmctsdemo") ? "8999dec3-0104-4a27-94ee-6588559729d1" : "bf308a5c-0624-4334-8ff8-8dca9fd43783"}"
  jenkins_rg              = "${(var.env == "prod" || var.env == "aat") ? "mgmt-infra-prod" : "mgmt-infra-sandbox"}"
  jenkins_vnet            = "${(var.env == "sandbox" || var.env == "saat" || var.env == "sprod") ? "mgmt-infra-sandbox" : "mgmt-infra-prod"}"
  bastion_subscription_id = "${(var.env == "prod" || var.env == "aat") ? "3682dd80-1150-444a-868d-4879d6605399" : "ed302caf-ec27-4c64-a05e-85731c3ce90e"}"
  bastion_rg              = "${(var.env == "prod") ? (var.env == "aat" ) ? "betaProdCoreRG" : "betaPreProdCoreRG" : "reformMgmtCoreRG"}"
  bastion_vnet            = "${(var.env == "prod") ? (var.env == "aat" ) ? "betaProdVNet" : "betaPreProdVNet" : "reformMgmtCoreVNet"}"
  bastion_subnet_name     = "${(var.env == "prod") ? (var.env == "aat" ) ? "betaProdDataSN" : "betaPreProdDataSN" : "reformMgmtDmzSN"}"
  jenkins_subnet_id       = "/subscriptions/${local.jenkins_subscription_id}/resourceGroups/${local.jenkins_rg}/providers/Microsoft.Network/virtualNetworks/${local.jenkins_vnet}subnets/${var.jenkins_subnet_name}"
  bastion_subnet_id       = "/subscriptions/${local.bastion_subscription_id}/resourceGroups/${local.bastion_rg}/providers/Microsoft.Network/virtualNetworks/${local.bastion_vnet}/subnets/${local.bastion_subnet_name}"
  ase_subnet_id           = "${data.azurerm_subnet.ase.id}"
  ase_vnet_rule_name      = "${var.env}ASEVNET"
  bastion_vnet_rule_name  = "${var.env}BastionVNET"
  jenkins_vnet_rule_name  = "${var.env}JenkinsVNET"
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
    BastionVnetRuleName        = "${local.bastion_vnet_rule_name}"
    BastionSubnetId            = "${local.bastion_subnet_id}"
    JenkinsVnetRuleName        = "${local.jenkins_vnet_rule_name}"
    JenkinsSubnetId            = "${local.jenkins_subnet_id}"
  }
}
