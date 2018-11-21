variable "product" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "postgresql_listen_port" {
  type    = "string"
  default = "5432"
}

variable "postgresql_user" {
  type = "string"
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
  type    = "string"
  default = "GP_Gen5_2"
}

variable "sku_tier" {
  type    = "string"
  default = "GeneralPurpose"
}

# Valid values are 9.5, 9.6 and 10.
variable "postgresql_version" {
  type    = "string"
  default = "9.6"
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
  type    = "string"
  default = "51200"
}

# Possible values are Enabled and Disabled.
variable "ssl_enforcement" {
  type    = "string"
  default = "Enabled"
}

# Min 7 days, max 35 days
variable "backup_retention_days" {
  type    = "string"
  default = "7"
}

# Possible values are Enabled and Disabled.
variable "georedundant_backup" {
  type    = "string"
  default = "Enabled"
}

variable "charset" {
  type    = "string"
  default = "utf8"
}

variable "collation" {
  type    = "string"
  default = "en_GB"
}

variable "database_name" {
  type = "string"
}

variable "common_tags" {
  type = "map"
}

#vnet rules
variable "jenkins_subnet_name" {
  type = "string"
  default = "jenkins-subnet"
}

variable "DCD-CNP-Prod_subscirption_id" {
  type = "string"
  default = "8999dec3-0104-4a27-94ee-6588559729d1"
}

variable "DCD-CFT-Sandbox_subscirption_id" {
  type = "string"
  default = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
}

variable "Reform-CFT-Prod_subscirption_id" {
  type = "string"
  default = "3682dd80-1150-444a-868d-4879d6605399"
}

variable "Reform-CFT-Mgmt_subscirption_id" {
  type = "string"
  default = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
}