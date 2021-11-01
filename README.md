# cnp-module-postgres

A module that lets you create an Azure Database for PostgreSQL.
Refer to the following links for a detailed explanation of the Azure Database for PostgreSQL.

[Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/overview) <br />

## Usage

The following example shows how to use the module to create an Azure Database for PostgreSQL instance and expose the host and port as environment variables in another module.

```terraform
module "database" {
  source                = "git@github.com:hmcts/cnp-module-postgres?ref=master"
  product               = var.product
  component             = var.component
  location              = var.location
  env                   = var.env
  postgresql_user       = var.postgresql_user
  database_name         = myproduct
  postgresql_version    = 10
  common_tags           = var.common_tags
  subscription          = var.subscription
}
```

## Variables

### Configuration

The following parameters are required by this module

- `product` the name of the product or project i.e. probate, divorce etc
- `component` the name of the component, i.e. data-store-api
- `location` the azure region for this service. _Note:_ Check to ensure the service is available in the region.
- `env` this is used to differentiate the environments e.g dev, prod, test etc
- `postgresql_user` the username for the admin database login. Cannot be 'azure_superuser', 'azure_pg_admin', 'admin', 'administrator', 'postgres', 'root', 'guest', or 'public'. It can't start with 'pg_'.
- `database_name` the name of the database to create within the Postgres server.  Please note currently, hyphens are NOT allowed in the database name and will be removed automatically to ensure a successful deployment.
- `common_tags` tags that need to be applied to every resource group, passed through by the jenkins-library
- `subscription` the subscription this module is currently being run in
- `postgresql_version` the postgres version. Currently 10 and 11.

**If you are using the SDS platform then you will need to add Key Vault parameters as per below**
```terraform
  key_vault_rg       = "genesis-rg"
  key_vault_name     = "dtssharedservices${var.environment}kv"
```

The following parameters are optional

- `sku_name` the size of the postgres instance, specifically cores. Default is "GP_Gen5_2".
- `sku_tier` Basic, Generanl Purpose or Memory Optimised.  Note that the sku_name chosen must belong to the sku_tier. Default is "GeneralPurpose"
- `sku_capacity` The number of vCores. Default is 2, note the database is charged per vCore/month
- `storage_mb` the amount of storage available to the DB instance.  Default is "51200".
- `ssl_enforcement` specifies whether SSL is enabled on the DB endpoint, options are "true" and "false"  Default is "true".
- `backup_retention_days` number of days to retain a backup. Default is 35.
- `georedundant_backup` specifies whether to use geo-redundant backup over local. Default is "Enabled".

### Output

The following variables are provided by the module for use in other modules

- `host_name` the host name which can be used to connect to PostgreSQL
- `postgresql_listen_port` the port to connect to
- `user_name` the username given in `postgresql_user` combined with the server name in the format postgresql_user@postgres-paas.name
- `postgresql_database`
- `postgresql_password` the randomly generated password for the admin login. It will be 16 characters and contain characters from three of the following categories: English uppercase letters, English lowercase letters, numbers (0 through 9), and nonalphanumeric characters (!, $, #, %, etc.).
- `resource_group_name` the resource group name of the PostgreSQL database resource
- `name` the server name of the PostgreSQL database resource


## Access to databases

Databases are restricted to access from specific subnets, these can be updated in the [cnp-database-subnet-whitelisting](https://github.com/hmcts/cnp-database-subnet-whitelisting)
GitHub repo.

Typically, you will need to set up an SSH tunnel to access the database you want to.

All developers can access non production databases with reader access.

Security cleared developers can access production DBs using just in time access and an approved business justification.

_Note: access is only granted on a case by case basis, and is removed automatically_

More process details to follow, it's currently being worked out.

### Non production:

First you will need to request access to the bastion via [JIT](https://myaccess.microsoft.com/@CJSCommonPlatform.onmicrosoft.com#/access-packages),
select the 'Non-Production Bastion Server Access' access package

```bash
POSTGRES_HOST=rpe-draft-store-aat.postgres.database.azure.com

ssh -N bastion-dev-nonprod.platform.hmcts.net -L 5440:${POSTGRES_HOST}:5432
# expect no more output in this terminal you won't get an interactive prompt

# in a separate terminal run:
PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)
DB_NAME=draftstore
DB_USER="DTS\ CFT\ DB\ Access\ Reader@rpe-draft-store-aat" # read access
#DB_USER="DTS\ Platform\ Operations@rpe-draft-store-aat" # operations team administrative access

psql "sslmode=require host=localhost port=5440 dbname=${DB_NAME} user=${DB_USER}"
```

### Production

First you will need to request access to the bastion via [JIT](https://myaccess.microsoft.com/@CJSCommonPlatform.onmicrosoft.com#/access-packages),
select the 'DevOps Bastion Server Access'.

The format for the reader group name is:

> DTS JIT Access ${var.product} DB Reader SC

Replace `var.product` with the product name of the db e.g. ccd

_Note: all spaces need to be escaped with a backslash (\) if you are using psql to authenticate_

```bash
POSTGRES_HOST=rpe-draft-store-prod.postgres.database.azure.com

ssh -N bastion-devops-prod.platform.hmcts.net -L 5440:${POSTGRES_HOST}:5432
# expect no more output in this terminal you won't get an interactive prompt

# in a separate terminal run:
PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)
DB_NAME=draftstore
DB_USER="DTS\ JIT\ Access\ draft-store\ DB\ Reader\ SC@rpe-draft-store-prod" # read access
#DB_USER="DTS\ Platform\ Operations\ SC@rpe-draft-store-prod" # operations team administrative access

psql "sslmode=require host=localhost port=5440 dbname=${DB_NAME} user=${DB_USER}"
```
