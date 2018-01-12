resource "azurerm_resource_group" "data-resourcegroup" {
  name     = "${var.product}-data-${var.env}"
  location = "${var.location}"
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
  }
}
