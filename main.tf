resource "random_string" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  number  = true
}

resource "azurerm_postgresql_server" "postgres_server" {
  name                = "${var.postgresql_server_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name     = "${var.postgresql_server_sku_name}"
    capacity = "${var.postgresql_server_sku_capacity}"
    tier     = "${var.postgresql_server_sku_tier}"
    family   = "${var.postgresql_server_sku_family}"
  }
  
  storage_profile {
    storage_mb = "${var.storage_mb}"
    backup_retention_days = "${var.backup_retention_days}"
    geo_redundant_backup = "${var.geo_redundant_backup}"
  }

  administrator_login          = "${var.administrator_login}"
  administrator_login_password = "${random_string.password.result}"
  version                      = "${var.version}"
  ssl_enforcement              = "${var.ssl_enforcement}"

  tags {
    "Deployment Environment" = "${var.env}"
    "Team Name"              = "${var.team_name}"
    "Team Contact"           = "${var.team_contact}"
    "Destroy Me"             = "${var.destroy_me}"
  }
}

resource "azurerm_postgresql_database" "postgresql-database" {
  name                = "${var.postgresql_database_name}"
  resource_group_name = "${var.resource_group_name}"
  server_name         = "${azurerm_postgresql_server.postgres_server.name}"
  charset             = "${var.charset}"
  collation           = "${var.collation}"
}

//TODO ADD SERVER FIREWALL RULES HERE

