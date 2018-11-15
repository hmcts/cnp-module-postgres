provider "azurerm" {
  alias = "mgmt"
}

locals { 
  ase_subnet_id          = "${data.azurerm_subnet.ase_subnet.id}"
  bastion_subnet_id      = "${data.azurerm_subnet.bastion_subnet.id}"
  jenkins_subnet_id      = "${data.azurerm_subnet.jenkins_subnet.id}"
  ase_vnet_rule_name     = "${var.env}ASEVNET"
  bastion_vnet_rule_name = "${var.env}BastionVNET"
  jenkins_vnet_rule_name = "${var.env}JenkinsVNET"
  mgmt_network_name         = "${var.subscription == "prod" || var.subscription == "hmctsdemo" ? "mgmt-infra-prod" : "mgmt-infra-sandbox"}"
  mgmt_network_rg_name      = "${var.subscription == "prod" || var.subscription == "hmctsdemo" ? "mgmt-infra-prod" : "mgmt-infra-sandbox"}"
  ASE_network_name          = "core-infra-vnet-${var.env}"
  bastion_network_name      = "reformMgmtCoreVNet"
  bation_rg_name            = "reformMgmtCoreRG"
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

data "azurerm_subnet" "jenkins_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "jenkins-subnet"
  virtual_network_name = "${local.mgmt_network_name}"
  resource_group_name  = "${local.mgmt_network_rg_name}"
}

data "azurerm_subnet" "bastion_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "reformMgmtDmzSN"
  virtual_network_name = "${local.bastion_network_name}"
  resource_group_name  = "${local.bation_rg_name}"
}

data "azurerm_subnet" "ase_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "core-infra-subnet-3-aat"
  virtual_network_name = "${local.ASE_network_name}"
  resource_group_name  = "core-infra-${var.env}"
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
