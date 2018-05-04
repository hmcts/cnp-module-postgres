resource "random_string" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  number  = true
}

resource "azurerm_postgresql_server" "postgres_server" {
  name                = "${var.product}-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  sku {
    name     = "${var.postgresql_server_sku_name}"
    capacity = "${var.postgresql_server_sku_capacity}"
    tier     = "${var.postgresql_server_sku_tier}"
  }

  administrator_login          = "${var.administrator_login}"
  administrator_login_password = "${random_string.password.result}"
  version                      = "${var.version}"
  storage_mb                   = "${var.storage_mb}"
  ssl_enforcement              = "${var.ssl_enforcement}"

  tags {
    "Deployment Environment" = "${var.env}"
    "Team Name"              = "${var.team_name}"
    "Team Contact"           = "${var.team_contact}"
    "Destroy Me"             = "${var.destroy_me}"
  }
}

resource "azurerm_postgresql_database" "postgresql-database" {
  name                = ""
  resource_group_name = "${var.resource_group_name}"
  server_name         = "${azurerm_postgresql_server.postgres_server.name}"
  charset             = "${var.charset}"
  collation           = "${var.collation}"

  tags {
    "Deployment Environment" = "${var.env}"
    "Team Name"              = "${var.team_name}"
    "Team Contact"           = "${var.team_contact}"
    "Destroy Me"             = "${var.destroy_me}"
  }
}

//TODO ADD SERVER FIREWALL RULES HERE

