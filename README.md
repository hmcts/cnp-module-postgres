# cnp-module-postgres

A module that lets you create an Azure Database for PostgreSQL.
Refer to the following links for a detailed explanation of the Azure Database for PostgreSQL.

[Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/overview) <br />

## Variables

### Configuration

The following parameters are required by this module

- `product` the name of the product or project i.e. probate, divorce etc
- `location` the azure region for this service. _Note:_ Check to ensure the service is available in the region.
- `env` this is used to differentiate the environments e.g dev, prod, test etc
- `postgresql_user` the username for the admin database login. Cannot be 'azure_superuser', 'azure_pg_admin', 'admin', 'administrator', 'postgres', 'root', 'guest', or 'public'. It can't start with 'pg_'.
- `database_name` the name of the database to create within the Postgres server.  Please note currently, hyphens are NOT allowed in the database name and will be removed automatically to ensure a successful deployment.
- `common_tags` tags that need to be applied to every resource group, passed through by the jenkins-library
- `subscription` the subscription this module is currently being run in

The following parameters are optional

- `sku_name` the size of the postgres instance, specifically cores. Default is "GP_Gen5_2".
- `sku_tier` Basic, Generanl Purpose or Memory Optimised.  Note that the sku_name chosen must belong to the sku_tier. Default is "GeneralPurpose"
- `sku_capacity` The number of vCores. Default is 2, note the database is charged per vCore/month
- `postgresql_version` the postgres version. Currently 9.5, 9.6, 10 and 11. Default is 9.6.
- `storage_mb` the amount of storage available to the DB instance.  Default is "51200".
- `ssl_enforcement` specifies whether SSL is enabled on the DB endpoint, options are "true" and "false"  Default is "true".
- `backup_retention_days` number of days to retain a backup. Default is 35.
- `georedundant_backup` specifies whether to use geo-redundant backup over local. Default is "Enabled".

### Access to databases

Databases are restricted to access from specific subnets, these can be updated [here](https://github.com/hmcts/cnp-database-subnet-whitelisting)
Typically you will need to setup an SSH tunnel to access the database you want to

```
$ ssh bastion.reform -L 5440:rhubarb-sandbox.postgres.database.azure.com:5432

$ psql -p 5440 -h localhost -U rhubarbadmin@rhubarb-sandbox -d rhubarb
```

The password can be retrieved from vault if you've stored it there, or if you view your applications settings.

Currently developers can only access databases in the sandbox subscription
The DevOps team can access nonprod databases from the preprod backup box and production databases from the production backup box

### Output

The following variables are provided by the module for use in other modules

- `host_name` the host name which can be used to connect to PostgreSQL
- `postgresql_listen_port` the port to connect to
- `user_name` the username given in `postgresql_user` combined with the server name in the format postgresql_user@postgres-paas.name
- `postgresql_database`
- `postgresql_password` the randomly generated password for the admin login. It will be 16 characters and contain characters from three of the following categories: English uppercase letters, English lowercase letters, numbers (0 through 9), and nonalphanumeric characters (!, $, #, %, etc.).

## Usage

The following example shows how to use the module to create an Azure Database for PostgreSQL instance and expose the host and port as environment variables in another module.

```terraform
module "database" {
  source                = "git@github.com:hmcts/cnp-module-postgres?ref=master"
  product               = "${var.product}"
  location              = "${var.location}"
  env                   = "${var.env}"
  postgresql_user       = "${var.postgresql_user}"
  database_name         = "myproduct"
  postgresql_version    = "10"
  common_tags           = "${var.common_tags}"
  subscription          = "${var.subscription}"
}

module "backend" {
  source      = "git@github.com:hmcts/moj-module-webapp?ref=master"
  product     = "${var.product}-backend"
  location    = "${var.location}"
  env         = "${var.env}"
  asename     = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"
  common_tags = "${var.common_tags}"

  app_settings = {
    POSTGRES_HOST     = "${module.database.host_name}"
    POSTGRES_PORT     = "${module.database.postgresql_listen_port}"
    POSTGRES_DATABASE = "${module.database.postgresql_database}"
    POSTGRES_USER     = "${module.database.user_name}"
  }
}
