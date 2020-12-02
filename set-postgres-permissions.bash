#!/usr/bin/env bash

az login -u "${DB_MANAGER_USER_NAME}" -p "${DB_MANAGER_PASSWORD}" -t "${TENANT_ID}" > /dev/null

# shellcheck disable=SC2155
export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)

SQL_COMMAND="
CREATE ROLE \"${DB_READER_USER}\" WITH LOGIN IN ROLE azure_ad_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"${DB_READER_USER}\";
"

psql "sslmode=require host=${DB_HOST_NAME} dbname=${DB_NAME} user=${DB_USER}" -c "${SQL_COMMAND}"
