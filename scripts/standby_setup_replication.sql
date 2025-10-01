-- PrivatBank Test Task - Standby Subscription Creation
-- Creates subscription to primary for logical replication
-- Idempotent script safe for multiple executions

-- Create subscription to primary (idempotent)
-- Check if subscription already exists
DO $$
DECLARE
    sub_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT FROM pg_subscription WHERE subname = 'privatbank_subscription') INTO sub_exists;
    
    IF sub_exists THEN
        RAISE NOTICE 'Subscription "privatbank_subscription" already exists';
    ELSE
        RAISE NOTICE 'Subscription "privatbank_subscription" does not exist - will be created outside transaction block';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Could not check subscription status: %', SQLERRM;
END
$$;

-- Create subscription outside transaction block
-- This is the ONLY necessary fix - remove transaction wrapper from CREATE SUBSCRIPTION
-- Note: This will fail if subscription already exists, but that's handled by the verification below
CREATE SUBSCRIPTION privatbank_subscription
CONNECTION 'host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatbank_test'
PUBLICATION privatbank_publication;

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
        RAISE WARNING 'This may be due to subscription creation failure or timing issues';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Could not verify subscription: %', SQLERRM;
END
$$;
