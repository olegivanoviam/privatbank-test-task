#!/bin/bash
set -e

# Check if PostgreSQL is ready
pg_isready -U postgres -d privatebank_test

# Check if replication is set up
psql -U postgres -d privatebank_test -c "SELECT 1 FROM pg_publication WHERE pubname = 'privatbank_publication';" > /dev/null 2>&1

echo "Primary database and replication are ready!"