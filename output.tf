output "host_name" {
  value = "${azurerm_template_deployment.postgres-paas.name}.postgres.database.azure.com"
}

output "postgresql_listen_port" {
  value = "${var.postgresql_listen_port}"
}

output "postgresql_database" {
  value = "${var.postgresql_database}"
}

output "user_name" {
  value = "${var.probate_postgresql_user}@${var.product}-${var.env}"
}
