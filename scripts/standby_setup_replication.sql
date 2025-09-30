-- PrivatBank Test Task - Standby Subscription Creation
-- Creates subscription to primary for logical replication

-- Create subscription to primary
CREATE SUBSCRIPTION privatbank_subscription
CONNECTION 'host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatebank_test'
PUBLICATION privatbank_publication;
