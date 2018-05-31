//SHARED VARIABLES
variable "product" {
  type        = "string"
  description = "The name of your application"
}

variable "env" {
  type        = "string"
  description = "The deployment environment (sandbox, aat, prod etc..)"
}

variable "location" {
  type        = "string"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "UK South"
}

variable "resource_group_name" {
  type        = "string"
  description = "This is the prefix your resource group name will have for your shared infrastructure"
}

//POSTGRES MODULE SPECIFIC VARIABLES
variable "postgresql_server_name" {
  type        = "string"
  description = "The name of your PostgreSQL Server"
}

variable "postgresql_database_name" {
  type        = "string"
  description = "The name of your PostgreSQL Database"
}

variable "postgresql_server_sku_name" {
  type        = "string"
  description = "(Required) Specifies the SKU Name for this PostgreSQL Server. The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen4_1, GP_Gen5_8). For more information see the product documentation."
  default     = "B_Gen5_2"
}

variable "postgresql_server_sku_family" {
  type        = "string"
  description = "(Required) The family of hardware Gen4 or Gen5, before selecting your family check the product documentation for availability in your region."
  default     = "Gen5"
}

variable "postgresql_server_sku_capacity" {
  description = "((Required) The scale up/out capacity, representing server's compute units."
  default     = 2
}

variable "postgresql_server_sku_tier" {
  type        = "string"
  description = "(Required) The tier of the particular SKU. Possible values are Basic, GeneralPurpose, and MemoryOptimized. For more information see the product documentation."
  default     = "GeneralPurpose"
}

variable "administrator_login" {
  type        = "string"
  description = "(Required) The Administrator Login for the PostgreSQL Server. Changing this forces a new resource to be created."
}

variable "version" {
  type        = "string"
  description = "(Required) Specifies the version of PostgreSQL to use. Valid values are 9.5 and 9.6. Changing this forces a new resource to be created."
  default     = "9.6"
}

variable "storage_mb" {
  type        = "string"
  description = "(Required) Max storage allowed for a server, possible values are between 5120 MB (5GB) and 1048576 MB (1TB). The step for this value must be in 1024 MB (1GB) increments. For more information see the product documentation."
  default     = "5120"
}

variable "ssl_enforcement" {
  type        = "string"
  description = "(Required) Specifies if SSL should be enforced on connections. Possible values are Enabled and Disabled."
  default     = "Enabled"
}

variable "charset" {
  type        = "string"
  description = "(Required) Specifies the Charset for the PostgreSQL Database, which needs to be a valid PostgreSQL Charset. Changing this forces a new resource to be created."
  default     = "UTF8"
}

variable "collation" {
  type        = "string"
  description = "(Required) Specifies the Collation for the PostgreSQL Database, which needs to be a valid PostgreSQL Collation. Note that Microsoft uses different notation - en-US instead of en_US. Changing this forces a new resource to be created."
  default     = "English_United States.1252"
}

//TAG SPECIFIC VARIABLES
variable "team_name" {
  type        = "string"
  description = "The name of your team"
  default     = "Not Supplied"
}

variable "team_contact" {
  type        = "string"
  description = "The name of your Slack channel people can use to contact your team about your infrastructure"
  default     = "Not Supplied"
}

variable "destroy_me" {
  type        = "string"
  description = "Here be dragons! In the future if this is set to Yes then automation will delete this resource on a schedule. Please set to No unless you know what you are doing"
  default     = "No"
}
