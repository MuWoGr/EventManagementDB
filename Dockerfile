FROM mdillon/postgis

COPY db_table_creation.sql /docker-entrypoint-initdb.d/q-init-1.sql
COPY db_table_add_constraints.sql /docker-entrypoint-initdb.d/q-init-2.sql