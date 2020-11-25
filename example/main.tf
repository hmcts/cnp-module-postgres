module "db" {
  source             = "../"
  common_tags        = var.common_tags
  database_name      = "test"
  env                = var.env
  location           = var.location
  postgresql_user    = "test"
  product            = var.product
  component          = var.component
  name               = var.product
  subscription       = var.subscription
  postgresql_version = "11"
}
