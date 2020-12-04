data "azurerm_subnet" "postgres" {
  name                 = "aks"
  resource_group_name  = "core-infra-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
}

module "db" {
  providers = {
    azurerm             = azurerm
    azurerm.private_dns = azurerm.private_dns
  }

  source             = "../"

  product            = var.product
  component          = var.component
  name               = var.product
  subscription       = var.subscription
  env                = var.env

  database_name      = "test"
  postgresql_user    = "test"
  postgresql_version = "11"

  subnet_id          = data.azurerm_subnet.postgres.id

  location           = var.location
  common_tags        = var.common_tags
}
