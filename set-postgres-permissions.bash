#!/usr/bin/env bash

CI_AZURE_FOLDER="${HOME}/.azure-${AZURE_SUBSCRIPTION_SHORT_NAME}"

if [ -d "${CI_AZURE_FOLDER}" ]
then
    echo "Overriding AZURE_CONFIG_DIR to ${CI_AZURE_FOLDER}"
    export AZURE_CONFIG_DIR="${CI_AZURE_FOLDER}"
else
    echo "Directory ${HOME}/.azure-${AZURE_SUBSCRIPTION_SHORT_NAME} does not exist."
fi

# shellcheck disable=SC2155
export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)

SQL_COMMAND="
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO PUBLIC;
DROP ROLE IF EXISTS \"${DB_READER_USER}\";
CREATE ROLE \"${DB_READER_USER}\" WITH LOGIN IN ROLE azure_ad_user;
"

psql "sslmode=require host=${DB_HOST_NAME} dbname=${DB_NAME} user=${DB_USER}" -c "${SQL_COMMAND}"
