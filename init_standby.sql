-- PrivatBank Test Task - Standby Database Initialization
-- This script initializes the standby database for logical replication

-- ==============================================
-- STEP 1: CREATE DATABASE SCHEMA
-- ==============================================

-- Create the same table structure as primary
\i schema/standby/create_table_t1.sql

-- ==============================================
-- STEP 2: CREATE INDEXES
-- ==============================================

-- Indexes are created as part of create_table_t1.sql

-- ==============================================
-- STEP 3: SETUP REPLICATION
-- ==============================================

-- Set up replica identity for logical replication
\i schema/standby/setup_replication.sql

-- ==============================================
-- STEP 4: CREATE SUBSCRIPTION
-- ==============================================

-- Try to create subscription to primary
-- If this fails due to timing, it will be handled by the retry script
\i scripts/standby_setup_replication.sql

-- ==============================================
-- STEP 5: FALLBACK SUBSCRIPTION CREATION
-- ==============================================

-- If subscription creation failed, provide instructions for manual creation
DO $$
BEGIN
    -- Check if subscription was created successfully
    IF NOT EXISTS (SELECT 1 FROM pg_subscription WHERE subname = 'privatbank_subscription') THEN
        RAISE NOTICE 'Subscription creation may have failed due to timing.';
        RAISE NOTICE 'If replication is not working, run the following command manually:';
        RAISE NOTICE 'CREATE SUBSCRIPTION privatbank_subscription';
        RAISE NOTICE 'CONNECTION ''host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatebank_test''';
        RAISE NOTICE 'PUBLICATION privatbank_publication;';
    ELSE
        RAISE NOTICE 'Subscription privatbank_subscription created successfully!';
    END IF;
END $$;

-- ==============================================
-- INITIALIZATION COMPLETE
-- ==============================================

SELECT 'Standby database initialization completed successfully!' as status;
SELECT 'Replication is ready!' as message;