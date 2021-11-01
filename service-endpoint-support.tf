locals {
  list_of_subnets = var.subnet_id == "" ? split(";", data.external.subnet_rules[0].result.subnets) : []
  list_of_rules   = var.subnet_id == "" ? split(";", data.external.subnet_rules[0].result.rule_names) : []

  db_rules = null_resource.subnet_mappings.*.triggers
}

data "azurerm_key_vault_secret" "github_api_key" {
  count = var.subnet_id == "" ? 1 : 0

  name         = "hmcts-github-apikey"
  key_vault_id = data.azurerm_key_vault.infra_vault.id
}

# https://gist.github.com/brikis98/f3fe2ae06f996b40b55eebcb74ed9a9e
resource "null_resource" "subnet_mappings" {
  count = var.subnet_id == "" ? length(local.list_of_subnets) : 0

  triggers = {
    rule_name = element(local.list_of_rules, count.index)
    subnet_id = element(local.list_of_subnets, count.index)
  }

}

data "external" "subnet_rules" {
  count = var.subnet_id == "" ? 1 : 0

  program = ["python3", "${path.module}/find-subnets.py"]
  query = {
    env              = var.env
    product          = var.product
    github_token     = data.azurerm_key_vault_secret.github_api_key[0].value
    subnets_filename = var.subnets_filename
  }
}

resource "azurerm_postgresql_virtual_network_rule" "postgres-vnet-rule" {
  for_each                             = { for db_rule in var.subnet_id == "" ? local.db_rules : [] : db_rule.rule_name => db_rule }
  name                                 = each.value.rule_name
  resource_group_name                  = azurerm_resource_group.data-resourcegroup.name
  server_name                          = local.server_name
  subnet_id                            = each.value.subnet_id
  ignore_missing_vnet_service_endpoint = true

  depends_on = [
    azurerm_postgresql_database.postgres-db
  ]
}
