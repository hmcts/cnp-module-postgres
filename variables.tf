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

#variable used to build the jenkins-subnet subnetid.
variable "jenkins_subnet_name" {
  type    = "string"
  default = "jenkins-subnet"
}
#is_asev2_present will create the rule that will allow apps inside ASEv2 to access the deployed DB.
variable "is_asev2_present" {
  type    = "string"
  default = "true"
}
#is_idam_idm variable will create the vnet rule that will allow sidam's IDM scalesets to connect to their db when the value is set to "true".
variable "is_idam_idm" {
  type    = "string"
  default = "false"
}
#is_idam_api variable will create the vnet rule that will allow apps hosted inside sidam's ASE to connect to their db when the value is set to "true".
variable "is_idam_api" {
  type    = "string"
  default = "false"
}
#idam_jumpbox variable will create the vnet rule that will allow sidam's Jumpbox to connect to sidam's dbs when the vaule is set to "true".
variable "idam_jumpbox" {
  type    = "string"
  default = "false"
}