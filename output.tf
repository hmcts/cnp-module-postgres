output "host_name" {
  value = "${azurerm_template_deployment.postgres-paas.name}.postgres.database.azure.com"
}

output "postgresql_listen_port" {
  value = "${var.postgresql_listen_port}"
}

output "postgresql_database" {
  value = "${replace(var.database_name, "-", "")}"
}

output "postgresql_password" {
  value = "${random_string.password.result}"
}

output "user_name" {
  value = "${var.postgresql_user}@${azurerm_template_deployment.postgres-paas.name}"
}

output "db_subnet_rules" {
  value = "${local.db_rules}"
}

output "name" {
  value = "${azurerm_template_deployment.postgres-paas.name}"
}
