# moj-module-postgres

A module that lets you create an Azure Database for PostgreSQL.
Refer to the following links for a detailed explanation of the Azure Database for PostgreSQL.

[Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/overview) <br />

## Variables

### Configuration

The following parameters are required by this module

- `product` the name of the product or project i.e. probate, divorce etc
- `location` the azure region for this service
- `env` this is used to differentiate the environments e.g dev, prod, test etc
- `postgresql_user` the username for the admin database login.
- `postgresql_password` the password for the admin login

### Output

The following variables are provided by the module for use in other modules

- `host_name` the host name which can be used to connect to PostgreSQL
- `postgresql_listen_port` the port to connect to
- `postgresql_database`
- `user_name`  

## Usage

The following example shows how to use the module to create a Redis PaaS instance and expose
the host, port and access key as environment variables in another module.

```terraform
module "database" {
  source              = "git::https://23a108ab5ea17c28372a130d72aa60ea0761839b@github.com/contino/moj-module-postgres?ref=master"
  product             = "${var.product}"
  location            = "${var.location}"
  env                 = "${var.env}"
  postgresql_user     = "${var.postgresql_user}"
  postgresql_password = "${var.postgresql_password}"
}

module "backend" {
  source   = "git::https://23a108ab5ea17c28372a130d72aa60ea0761839b@github.com/contino/moj-module-webapp?ref=0.0.78"
  product  = "${var.product}-backend"
  location = "${var.location}"
  env      = "${var.env}"
  asename  = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"

  app_settings = {
    POSTGRES_HOST     = "${module.database.host_name}"
    POSTGRES_PORT     = "${module.database.postgresql_listen_port}"
    POSTGRES_DATABASE = "${module.database.postgresql_database}"
    POSTGRES_USER     = "${module.database.user_name}"
  }
}
