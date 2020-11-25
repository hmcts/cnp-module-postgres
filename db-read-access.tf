locals {
  db_reader_user = local.is_prod ? "DTS JIT Access ${var.product} DB Reader SC" : "DTS CFT DB Access Reader"
}

resource "null_resource" "set-user-permissions" {
  triggers = {
    script_hash    = filesha256("${path.module}/set-postgres-permissions.bash")
    name           = local.name
    db_reader_user = local.db_reader_user
  }

  provisioner "local-exec" {
    command = "${path.module}/set-postgres-permissions.bash"

    environment = {
      DB_NAME                       = replace(var.database_name, "-", "")
      DB_HOST_NAME                  = "${azurerm_template_deployment.postgres-paas.name}.postgres.database.azure.com"
      DB_USER                       = "${local.escaped_admin_group}@${azurerm_template_deployment.postgres-paas.name}"
      DB_READER_USER                = local.db_reader_user
      AZURE_SUBSCRIPTION_SHORT_NAME = var.subscription
    }
  }
  depends_on = [
    azurerm_postgresql_active_directory_administrator.admin
  ]

  # only run if component or name override is set
  # due to legacy reasons people put var.product and var.component in product
  # but we only want the product so introduced a new field which allowed teams to move over to this format
  count = (var.component != "" || var.name != "") ? 1 : 0
}