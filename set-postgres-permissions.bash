#!/usr/bin/env bash

export AZURE_CONFIG_DIR=~/.azure-db-manager
az login -u "${DB_MANAGER_USER_NAME}" -p "${DB_MANAGER_PASSWORD}" -t "${TENANT_ID}" >/dev/null

# shellcheck disable=SC2155
export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)

SQL_COMMAND="
DO
\$do\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles  -- SELECT list can be empty for this
      WHERE rolname = '${DB_READER_USER}') THEN

      CREATE ROLE \"${DB_READER_USER}\" WITH LOGIN IN ROLE azure_ad_user;
   END IF;
END
\$do\$;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"${DB_READER_USER}\";
"

## Delay until DB DNS and propagated 
COUNT=0;
MAX=10;
while true; do
   ping -c 1 $DB_HOST_NAME &>/dev/null
   if [[ $? -eq 0 ]]; then
      break
   fi
   if [[ $COUNT -eq $MAX ]]; then
      break
   else
      COUNT=$[$COUNT+1]
   fi
   sleep 5
done

psql "sslmode=require host=${DB_HOST_NAME} dbname=${DB_NAME} user=${DB_USER}" -c "${SQL_COMMAND}"
