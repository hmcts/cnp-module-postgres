variable "product" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "postgresql_user" {
  type = "string"
}

variable "postgresql_listen_port" {
  type    = "string"
  default = "5432"
}

variable "postgresql_database" {
  type    = "string"
  default = "postgres"
}

variable "common_tags" {
  type = "map"
  default = {}
}