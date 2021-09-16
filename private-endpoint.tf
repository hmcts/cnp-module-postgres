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

  private_dns_zone_group {
    name                 = "postgres-endpoint-dnszonegroup"
    private_dns_zone_ids = ["/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com"]
  }
  count = var.subnet_id == "" ? 0 : 1
  tags  = var.common_tags
}
