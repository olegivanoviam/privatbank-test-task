-- PrivatBank Test Task - Standby Subscription Creation
-- Creates subscription to primary for logical replication

-- Note: This script is called during initialization
-- If the subscription creation fails due to timing, it will be retried
-- The actual retry logic is handled by create_subscription_with_retry.sh

-- Create subscription to primary
CREATE SUBSCRIPTION privatbank_subscription
CONNECTION 'host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatebank_test'
PUBLICATION privatbank_publication;
