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

locals {
  mgmt_network_name = "${var.subscription == "prod" || var.subscription == "nonprod" ? "mgmt-infra-prod" : "mgmt-infra-sandbox"}"
  ASE_network_name = "core-infra-vnet-${var.env}"
  bastion_network_name = "reformMgmtCoreVNet"
  bation_rg_name = "reformMgmtCoreRG"
}

data "azurerm_subnet" "jenkins_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "jenkins-subnet"
  virtual_network_name = "${local.mgmt_network_name}"
  resource_group_name  = "${local.mgmt_network_name}"
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
  virtual_network_name = "${local.ASE_network_name }"
  resource_group_name  = "core-infra-${var.env}"
}

output "jenkins_subnet_id" {
  value = "${data.azurerm_subnet.jenkins_subnet.id}"
}

output "bastion_subnet_id" {
  value = "${data.azurerm_subnet.bastion_subnet.id}"
}

output "ase_subnet_id" {
  value = "${data.azurerm_subnet.ase_subnet.id}"
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
    AseVnetRuleName            = "${var.ase_vnet_rule_name}"
    AseSubnetId                = "${output.ase_subnet_id}"
    BastionVnetRuleName        = "${var.bastion_vnet_rule_name}"
    BastionSubnetId            = "${output.bastion_subnet_id}"
    JenkinsVnetRuleName        = "${var.jenkins_vnet_rule_name}"
    JenkinsSubnetId            = "${output.jenkins_subnet_id}"
  }
}
