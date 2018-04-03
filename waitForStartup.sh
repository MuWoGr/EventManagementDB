#!/bin/bash
set -e

echo "Starting database container" 

# Max query attempts before consider setup failed
MAX_TRIES=3

# Returns a true-like value if and only if a query
# with the expected db and user succeeds
function dbIsReady() {
  PGPASSWORD=password \
  psql -h localhost:54321 -U postgres \
       -d postgres -c "select 1" \
  > /dev/null 2>&1
}

echo "Wait for PostgreSQL to become available..."
sleep 5
until dbIsReady || [ $MAX_TRIES -eq 0 ]; do
  echo "Waiting for PostgreSQL server, $((MAX_TRIES--)) remaining attempts..."
  sleep 5
done

if [ $MAX_TRIES -eq 0 ]
then
  echo "Error: PostgreSQL not responding, cancelling server set up"
  exit 1
fi
