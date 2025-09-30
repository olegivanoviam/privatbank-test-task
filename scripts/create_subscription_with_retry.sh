#!/bin/bash

# PrivatBank Test Task - Subscription Creation with Retry
# This script creates the subscription with retry logic

MAX_RETRIES=30
RETRY_DELAY=2
SUBSCRIPTION_NAME="privatbank_subscription"
CONNECTION_STRING="host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatebank_test"
PUBLICATION_NAME="privatbank_publication"

echo "Starting subscription creation with retry mechanism..."

for attempt in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $attempt: Checking if subscription already exists..."
    
    # Check if subscription already exists
    if psql -U postgres -d privatebank_test -c "SELECT 1 FROM pg_subscription WHERE subname = '$SUBSCRIPTION_NAME';" | grep -q "1 row"; then
        echo "Subscription $SUBSCRIPTION_NAME already exists. Skipping creation."
        exit 0
    fi
    
    echo "Attempt $attempt: Trying to create subscription..."
    
    # Try to create subscription
    if psql -U postgres -d privatebank_test -c "CREATE SUBSCRIPTION $SUBSCRIPTION_NAME CONNECTION '$CONNECTION_STRING' PUBLICATION $PUBLICATION_NAME;" 2>/dev/null; then
        echo "Successfully created subscription $SUBSCRIPTION_NAME after $attempt attempts!"
        exit 0
    else
        echo "Attempt $attempt failed. Retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
    fi
done

echo "Failed to create subscription after $MAX_RETRIES attempts."
echo "You may need to create the subscription manually after both databases are ready."
exit 1
