-- PrivatBank Test Task - Standby Subscription Creation
-- Creates subscription to primary for logical replication
-- Idempotent script safe for multiple executions

-- Create subscription to primary (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_subscription WHERE subname = 'privatbank_subscription') THEN
        CREATE SUBSCRIPTION privatbank_subscription
        CONNECTION 'host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatbank_test'
        PUBLICATION privatbank_publication;
        RAISE NOTICE 'Subscription "privatbank_subscription" created successfully';
    ELSE
        RAISE NOTICE 'Subscription "privatbank_subscription" already exists';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Could not create subscription: %', SQLERRM;
        RAISE WARNING 'This may be due to primary server not being ready or connection issues';
END
$$;

-- Verify subscription creation
DO $$
DECLARE
    sub_exists BOOLEAN;
BEGIN
    -- Check if subscription exists
    SELECT EXISTS(SELECT FROM pg_subscription WHERE subname = 'privatbank_subscription') INTO sub_exists;
    
    IF sub_exists THEN
        RAISE NOTICE 'Subscription verification successful';
        RAISE NOTICE 'Subscription "privatbank_subscription" is ready for replication';
    ELSE
        RAISE WARNING 'Subscription verification failed - subscription not found';
    END IF;
END
$$;
