variable "product" {
  type = string
}

variable "component" {
  default = ""
}

variable "name" {
  default = ""
}

variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "postgresql_listen_port" {
  type    = string
  default = "5432"
}

variable "postgresql_user" {
  type = string
}

# sku supports the following:
# - skuName: Possible values are:
#            B_Gen5_1    (Basic)
#            B_Gen5_2    (Basic)
#            GP_Gen5_2   (GeneralPurpose)
#            GP_Gen5_4   (GeneralPurpose)
#            GP_Gen5_8   (GeneralPurpose)
#            GP_Gen5_16  (GeneralPurpose)
#            GP_Gen5_32  (GeneralPurpose)
#            MO_Gen5_2   (MemoryOptimised)
#            MO_Gen5_4   (MemoryOptimised)
#            MO_Gen5_8   (MemoryOptimised)
#            MO_Gen5_16  (MemoryOptimised)
#            MO_Gen5_32  (MemoryOptimised)

# - tier     : Specifies the SKU Tier for this PostgreSQL Server.
#              Possible values are "Basic", "GeneralPurpose", "MemoryOptimized".
variable "sku_name" {
  type    = string
  default = "GP_Gen5_2"
}

variable "sku_tier" {
  type    = string
  default = "GeneralPurpose"
}

# This is actually the vCores when template is run
variable "sku_capacity" {
  type    = string
  default = "2"
}

# Valid values are 10 and 11.
# https://docs.microsoft.com/en-us/azure/postgresql/concepts-version-policy
variable "postgresql_version" {
  type    = string
  default = "10"
}

# storage_mb supports the following
# When using a SKU Name of Basic:
# min: 5120
# max: 1048576
#
# When using a SKU Name of GeneralPurpose:
# min: 5120
# max: 2097152
#
# When using a SKU Name of MemoryOptimized:
# min: 5120
# max: 2097152

variable "storage_mb" {
  type    = string
  default = "51200"
}

# Possible values are Enabled and Disabled.
variable "ssl_enforcement" {
  type    = string
  default = "Enabled"
}

# Min 7 days, max 35 days
variable "backup_retention_days" {
  type    = string
  default = "35"
}

# Possible values are Enabled and Disabled.
variable "georedundant_backup" {
  type    = string
  default = "Enabled"
}

variable "charset" {
  type    = string
  default = "utf8"
}

variable "collation" {
  type    = string
  default = "en-GB"
}

variable "database_name" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "subscription" {
  description = "the human friendly name of the subscription, ie. qa, or prod"
}

variable "key_vault_name" {
  description = "the human friendly name of the key vault where the github api key resides"
  default     = ""
}

variable "key_vault_rg" {
  description = "the human friendly name of the resource group where the key vault resides"
  default     = ""
}

variable "subnets_filename" {
  description = "Filename of the subnets file in the cnp-database-subnet-whitelisting repo"
  default     = "subnets.json"
}

variable "business_area" {
  description = "Business Area."
  default     = "CFT"
}
