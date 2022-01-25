output "host_name" {
  value = "${azurerm_postgresql_server.postgres-paas.name}.postgres.database.azure.com"
}

output "postgresql_listen_port" {
  value = var.postgresql_listen_port
}

output "postgresql_database" {
  value = azurerm_postgresql_database.postgres-db.name
}

output "postgresql_password" {
  value = random_password.password.result
}

output "user_name" {
  value = "${var.postgresql_user}@${azurerm_postgresql_server.postgres-paas.name}"
}

output "name" {
  value = azurerm_postgresql_server.postgres-paas.name
}

output "resource_group_name" {
  value = azurerm_postgresql_server.postgres-paas.resource_group_name
}
output "id" {
  value = azurerm_postgresql_server.postgres-paas.id
}
