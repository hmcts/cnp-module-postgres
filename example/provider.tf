provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias           = "private_dns"
  subscription_id = var.private_dns_subscription_id
}
