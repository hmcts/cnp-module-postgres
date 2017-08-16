output "host_name" {
  value = "${azurerm_template_deployment.postgres-paas.name}.postgres.database.azure.com"
}
