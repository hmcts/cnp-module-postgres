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

The following parameters are optional

- `sku_name` the size of the postgres instance, specifically cores. Default is "GP_Gen5_2".
- `sku_tier` Basic, Generanl Purpose or Memory Optimised.  Note that the sku_name chosen must belong to the sku_tier. Default is "GeneralPurpose"
- `sku_capacity` The number of vCores. Default is 2, note the database is charged per vCore/month
- `postgresql_version` the postgres version. Currently 9.5, 9.6, 10 and 11. Default is 9.6.
- `storage_mb` the amount of storage available to the DB instance.  Default is "51200".
- `ssl_enforcement` specifies whether SSL is enabled on the DB endpoint.  Default is "Enabled".
- `backup_retention_days` number of days to retain a backup. Default is 35.
- `georedundant_backup` specifies whether to use geo-redundant backup over local. Default is "Enabled".

### Output

The following variables are provided by the module for use in other modules

- `host_name` the host name which can be used to connect to PostgreSQL
- `postgresql_listen_port` the port to connect to
- `user_name` the username given in `postgresql_user` combined with the server name in the format postgresql_user@postgres-paas.name
- `postgresql_database`
- `postgresql_password` the randomly generated password for the admin login. It will be 16 characters and contain characters from three of the following categories: English uppercase letters, English lowercase letters, numbers (0 through 9), and nonalphanumeric characters (!, $, #, %, etc.).


## Access to databases

Databases are restricted to access from specific subnets, these can be updated in the [cnp-database-subnet-whitelisting](https://github.com/hmcts/cnp-database-subnet-whitelisting)
GitHub repo.

Typically, you will need to set up an SSH tunnel to access the database you want to.

All developers can access non production databases with reader access.

Security cleared developers can access production DBs using just in time access and an approved business justification.

_Note: access is only granted on a case by case basis, and is removed automatically_

More process details to follow, it's currently being worked out.

### Non production:

#### First time setup

1. Join the 'DTS CFT Developers' AAD group via [GitHub pull request](https://github.com/hmcts/devops-azure-ad/blob/master/users/prod_users.yml)
2. Add SSH config, this goes in `~/.ssh/config`, create the file if it doesn't exist

<details>

<summary>Bastion configuration</summary>

Update the user line to your email address

```shell
Host *.platform.hmcts.net
  User <your-email>@hmcts.net # must be lower case
  PubkeyAuthentication no
  ForwardAgent yes
```

</details>

#### Steps to access

1. Connect to the VPN
2. Request access to the non production bastion via [JIT](https://myaccess.microsoft.com/@HMCTS.NET#/access-packages/4894e58f-920e-404d-9db4-dc2ab8513794),
this will be automatically approved, and lasts for 24 hours.
3. Copy below script, update the variables (search for all references to draft-store and replace with your DB) and run it

```bash
# If you haven't logged in before you may need to login, uncomment the below line:
# az login 
# this should give you a long JWT token, you will need this later on
az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv

ssh bastion-dev-nonprod.platform.hmcts.net

export PGPASSWORD=<result-from-earlier>

# you can get this from the portal, or determine it via the inputs your pass to this module in your code
POSTGRES_HOST=rpe-draft-store-aat.postgres.database.azure.com

# this matches the `database_name` parameter you pass in the module
DB_NAME=draftstore

# Update the suffix after the @ to the server name
DB_USER="DTS\ CFT\ DB\ Access\ Reader@rpe-draft-store-aat" # read access
#DB_USER="DTS\ Platform\ Operations@rpe-draft-store-aat" # operations team administrative access

psql "sslmode=require host=${POSTGRES_HOST} dbname=${DB_NAME} user=${DB_USER}"
```

_Note: it's also possible to tunnel the connection to your own machine and use other tools to log in, IntelliJ database tools works, pgAdmin doesn't due to a hardcoded password length limit._

<details>

<summary>Tunnel version of the script</summary>

```shell
# you can get this from the portal, or determine it via the inputs your pass to this module in your code
POSTGRES_HOST=rpe-draft-store-aat.postgres.database.azure.com

ssh -N bastion-dev-nonprod.platform.hmcts.net -L 5440:${POSTGRES_HOST}:5432
# expect no more output in this terminal you won't get an interactive prompt

# in a separate terminal run:
export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)
# this matches the `database_name` parameter you pass in the module
DB_NAME=draftstore

# Update the suffix after the @ to the server name
DB_USER="DTS\ CFT\ DB\ Access\ Reader@rpe-draft-store-aat" # read access
#DB_USER="DTS\ Platform\ Operations@rpe-draft-store-aat" # operations team administrative access

psql "sslmode=require host=localhost port=5440 dbname=${DB_NAME} user=${DB_USER}"
```

</details>

### Production

#### First time setup

1. Join the 'DTS CFT Developers' AAD group via [GitHub pull request](https://github.com/hmcts/devops-azure-ad/blob/master/users/prod_users.yml)
2. Request access to production via [JIT](https://myaccess.microsoft.com/@HMCTS.NET#/access-packages/738a7496-7ad4-4004-8b05-0e98677f4a9f), this requires SC clearance, or an approved exception.
   _Note: after this is approved it can take some time for the other packages to show up, try logging out and back in._

3. Add SSH config, this goes in `~/.ssh/config`, create the file if it doesn't exist

<details>

<summary>Bastion configuration</summary>

Update the user line to your email address

```shell
Host *.platform.hmcts.net
  User <your-email>@hmcts.net # must be lower case
  PubkeyAuthentication no
  ForwardAgent yes
```

</details>

#### Steps to access

1. Request access to the database that you need via [JIT](https://myaccess.microsoft.com/@CJSCommonPlatform.onmicrosoft.com#/access-packages),
   the naming convention is `Database - <product> (read|write) access`.
2. Wait till it's approved, you can also message in #db-self-service on slack.
3. Connect to the VPN
4. Copy below script, update the variables (search for all references to draft-store and replace with your DB), and run it

```bash
# If you haven't logged in before you may need to login, uncomment the below line:
# az login 
# this should give you a long JWT token, you will need this later on
az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv

# follow the prompts to login
ssh bastion-devops-prod.platform.hmcts.net

export PGPASSWORD=<result-from-earlier>

# you can get this from the portal, or determine it via the inputs your pass to this module in your code
POSTGRES_HOST=rpe-draft-store-prod.postgres.database.azure.com

# this matches the `database_name` parameter you pass in the module
DB_NAME=draftstore

# make sure you update the product name in the middle to your product
# and also update the suffix after the @ to the server name
DB_USER="DTS\ JIT\ Access\ draft-store\ DB\ Reader\ SC@rpe-draft-store-prod" # read access
#DB_USER="DTS\ Platform\ Operations\ SC@rpe-draft-store-prod" # operations team administrative access

psql "sslmode=require host=${POSTGRES_HOST} dbname=${DB_NAME} user=${DB_USER}"
# note: some users have experienced caching issues with their AAD token:
# psql: error: FATAL:  Azure AD access token not valid for role DTS JIT Access send-letter DB Reader SC (does not contain group ID c9e865ee-bc88-40d9-a5c1-23831f0ce255)
# the fix is to clear the cache and login again: rm -rf ~/.azure && az login
```

_Note: it's also possible to tunnel the connection to your own machine and use other tools to log in, IntelliJ database tools works, pgAdmin doesn't due to a hardcoded password length limit._

<details>

<summary>Tunnel version of the script</summary>

```shell
# you can get this from the portal, or determine it via the inputs your pass to this module in your code
POSTGRES_HOST=rpe-draft-store-prod.postgres.database.azure.com

ssh -N bastion-devops-prod.platform.hmcts.net -L 5440:${POSTGRES_HOST}:5432
# expect no more output in this terminal you won't get an interactive prompt

# in a separate terminal run:
export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)

# this matches the `database_name` parameter you pass in the module
DB_NAME=draftstore

# make sure you update the product name in the middle to your product
# and also update the suffix after the @ to the server name
DB_USER="DTS\ JIT\ Access\ draft-store\ DB\ Reader\ SC@rpe-draft-store-prod" # read access
#DB_USER="DTS\ Platform\ Operations\ SC@rpe-draft-store-prod" # operations team administrative access

psql "sslmode=require host=localhost port=5440 dbname=${DB_NAME} user=${DB_USER}"
```

</details>
