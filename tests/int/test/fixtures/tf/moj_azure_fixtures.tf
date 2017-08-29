provider "azurerm" {}

variable "location" {
  default = "West Europe"
}

variable "product" {
  default = "inspec"
}

variable "random_name" {}

variable "env" {
  default = "int"
}

variable "postgresql_user" {
  type    = "string"
  default = "inspec"
}

variable "postgresql_password" {
  type    = "string"
  default = "0Tk3049&6k"
}

variable "postgresql_listen_port" {
  type    = "string"
  default = "5432"
}

variable "postgresql_database" {
  type    = "string"
  default = "postgres"
}

data "terraform_remote_state" "core_sandbox_infrastructure" {
  backend = "azure"

  config {
    resource_group_name  = "contino-moj-tf-state"
    storage_account_name = "continomojtfstate"
    container_name       = "contino-moj-tfstate-container"
    key                  = "sandbox-core-infra/dev/terraform.tfstate"
  }
}

module "db" {
  source              = "../../../../../"
  product             = "${var.random_name}-db"
  location            = "${var.location}"
  env                 = "${var.env}"
  postgresql_user     = "${var.postgresql_user}"
  postgresql_password = "${var.postgresql_password}"
  postgresql_database = "${var.postgresql_database}"
}

output "random_name" {
  value = "${var.random_name}"
}
