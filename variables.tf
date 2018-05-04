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
variable "postgres_server_name" {
  type = "string"
  description = "The name of your PostgreSQL Server"
}

variable "postgresql_database_name" {
  type = "string"
  description = "The name of your PostgreSQL Database"
}
variable "postgresql_server_sku_name" {
  type        = "string"
  description = "(Optional) Specifies the SKU Name for this PostgreSQL Server. Possible values are: PGSQLB50, PGSQLB100, PGSQLS100, PGSQLS200, PGSQLS400 and PGSQLS800"
  default     = "PGSQLB50"
}

variable "postgresql_server_sku_capacity" {
  description = "(Optional) Specifies the DTU's for this PostgreSQL Server. Possible values are 50 and 100 DTU's when using a Basic SKU and 100, 200, 400 or 800 when using the Standard SKU."
  default     = 100
}

variable "postgresql_server_sku_tier" {
  type        = "string"
  description = "(Optional) Specifies the SKU Tier for this PostgreSQL Server. Possible values are Basic and Standard."
  default     = "Standard"
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
  description = "(Required) Specifies the amount of storage for the PostgreSQL Server in Megabytes. Possible values are shown below. Changing this forces a new resource to be created.Possible values for storage_mb when using a SKU Name of Basic are: - 51200 (50GB) - 179200 (175GB) - 307200 (300GB) - 435200 (425GB) - 563200 (550GB) - 691200 (675GB) - 819200 (800GB) - 947200 (925GB) Possible values for storage_mb when using a SKU Name of Standard are: - 128000 (125GB) - 256000 (256GB) - 384000 (384GB) - 512000 (512GB) - 640000 (640GB) - 768000 (768GB) - 896000 (896GB) - 1024000 (1TB)"
  default     = "128000"
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
