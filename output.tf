output "postgresql_server_id" {
  value       = "${azurerm_postgresql_server.postgres_server.id}"
  description = "The ID of the PostGresSQL Server."
}

output "postgresql_server_fqdn" {
  value       = "${azurerm_postgresql_server.postgres_server.fqdn}"
  description = "The fully qualified domain name of the PostGresSQL Server."
}

output "postgresql_database_id" {
  value       = "${azurerm_postgresql_database.postgresql-database.id}"
  description = "The ID of the PostGreSQL Database."
}
