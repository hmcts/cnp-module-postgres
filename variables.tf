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

# sku supports the following:
# - name     : (Optional) Specifies the SKU Name for this PostgreSQL Server. 
#              Possible values are: PGSQLB50 
#                                   PGSQLB100
#                                   PGSQLS100
#                                   PGSQLS200
#                                   PGSQLS400
#                                   PGSQLS800
# - capacity : (Optional) Specifies the DTU's for this PostgreSQL Server.
#              Possible values (basic):    50
#                                          100
#              Possible values (standard): 100
#                                          200
#                                          400
#                                          800
# - tier     : (Optional) Specifies the SKU Tier for this PostgreSQL Server.
#              Possible values are Basic and Standard.
variable "sku_name" {
  type    = "string"
  default = "PGSQLB50"
}

variable "sku_capacity" {
  type = "string"
  default = "50"
}

variable "sku_tier" {
  type    = "string"
  default = "Basic"
}

# Valid values are 9.5 and 9.6.
variable "version" {
  type    = "string"
  default = "9.6"
}

# storage_mb supports the following
# When using a SKU Name of Basic:    51200 (50GB)
#                                    179200 (175GB)
#                                    307200 (300GB)
#                                    435200 (425GB)
#                                    563200 (550GB)
#                                    691200 (675GB)
#                                    819200 (800GB)
#                                    947200 (925GB)
# When using a SKU Name of Standard: 128000 (125GB)
#                                    256000 (256GB)
#                                    384000 (384GB)
#                                    512000 (512GB)
#                                    640000 (640GB)
#                                    768000 (768GB)
#                                    896000 (896GB)
#                                    1024000 (1TB)
variable "storage_mb" {
  type = "string"
  default = "51200"
}

# Possible values are Enabled and Disabled.
variable "ssl_enforcement" {
  type    = "string"
  default = "Disabled"
}

variable "firewall_start_ip" {
  type    = "string"
  default = "0.0.0.0"
}

variable "firewall_end_ip" {
  type    = "string"
  default = "0.0.0.0"
}