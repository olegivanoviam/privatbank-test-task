#!/bin/bash
set -e

# PrivatBank Test Task - Job Scheduler
# Runs both insert and update jobs with proper timing

echo "Starting PrivatBank Job Scheduler..."

# Wait for primary database to be ready
until pg_isready -h postgres-primary -p 5432 -U postgres -d privatbank_test; do
    echo "Waiting for primary postgres..."
    sleep 2
done

echo "Primary PostgreSQL is ready, starting job scheduler..."

# Run insert job every 5 seconds
while true; do
    echo "$(date): Running insert job..."
    
    # Execute insert job with error handling
    if psql -h postgres-primary -U postgres -d privatbank_test -c "SELECT job_insert_transaction();" > /dev/null 2>&1; then
        echo "$(date): Insert job completed successfully"
    else
        echo "$(date): ERROR - Insert job failed"
    fi
    
    sleep 5
done &

# Run update job every 3 seconds (in background)
while true; do
    echo "$(date): Running update job..."
    
    # Execute update job with error handling
    if psql -h postgres-primary -U postgres -d privatbank_test -c "SELECT job_update_status();" > /dev/null 2>&1; then
        echo "$(date): Update job completed successfully"
    else
        echo "$(date): ERROR - Update job failed"
    fi
    
    sleep 3
done &

# Wait for background processes
wait
