#!/bin/bash
set -e

# executing the given sql script on the db
function executeSQL() {
  PGPASSWORD=password \
  psql -h localhost -p 54323 \
       -U postgres -d postgres \
       -v "ON_ERROR_STOP=1" \
       -f "$1"
  > /dev/null 2>&1
}

executeSQL scripts/db_table_drop_constraints.sql
executeSQL scripts/db_table_drop_constraints.sql
executeSQL scripts/db_table_drop.sql
executeSQL scripts/db_table_creation.sql
executeSQL scripts/db_table_add_constraints.sql
