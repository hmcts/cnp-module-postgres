locals {
  replica_db_rules = flatten([for replica in var.replicas :
    [for network_rule in local.db_rules :
      {
        "rule_name"   = "${replica}-${network_rule.rule_name}"
        "server_name" = replica
        "subnet_id"   = network_rule.subnet_id
      }
    ]
  ])
}

data "azurerm_postgresql_server" "replica" {
  name                = local.server_name
  resource_group_name = azurerm_resource_group.data-resourcegroup.name
}

resource "azurerm_postgresql_server" "replica" {
  for_each = toset(var.replicas)

  name                = "${local.server_name}-${each.key}"
  location            = azurerm_resource_group.data-resourcegroup.location
  resource_group_name = azurerm_resource_group.data-resourcegroup.name

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false

  ssl_enforcement_enabled          = var.ssl_enforcement == "Enabled" ? true : false
  ssl_minimal_tls_version_enforced = "TLS1_2"

  administrator_login          = var.postgresql_user
  administrator_login_password = random_string.password.result

  create_mode               = "Replica"
  creation_source_server_id = data.azurerm_postgresql_server.replica.id

  tags = var.common_tags
}

resource "azurerm_postgresql_virtual_network_rule" "replica_rules" {

  for_each = { for db_rule in local.replica_db_rules : db_rule.rule_name => db_rule }

  name                                 = each.value.rule_name
  resource_group_name                  = azurerm_resource_group.data-resourcegroup.name
  server_name                          = azurerm_postgresql_server.replica[each.value.server_name].name
  subnet_id                            = each.value.subnet_id
  ignore_missing_vnet_service_endpoint = true
}
