resource "azurerm_private_endpoint" "postgres" {
  name                = "${var.product}-${var.env}-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.product}-${var.env}-db"
    private_connection_resource_id = azurerm_postgresql_server.postgres-paas.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  count = var.subnet_id == "" ? 0 : 1
  tags  = var.common_tags
}
