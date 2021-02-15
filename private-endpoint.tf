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
    private_dns_zone_ids = [data.azurerm_private_dns_zone.postgres.id]
  }
  count = var.subnet_id == "" ? 0 : 1
}

# resource "azurerm_private_dns_a_record" "postgres" {
#   provider = azurerm.private_dns

#   name                = azurerm_postgresql_server.postgres-paas.name
#   zone_name           = "privatelink.postgres.database.azure.com"
#   resource_group_name = "core-infra-intsvc-rg"
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.postgres[0].private_service_connection[0].private_ip_address]

#   count = var.subnet_id == "" ? 0 : 1
# }
