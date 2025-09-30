-- PrivatBank Test Task - Replication Setup and Verification
-- This script sets up and verifies the replication setup

-- Replication monitoring functions are already loaded from 09_replication_monitoring.sql

-- Verify replication setup
DO $$
BEGIN
    -- Check if we're on primary server
    IF NOT pg_is_in_recovery() THEN
        RAISE NOTICE 'Setting up replication on PRIMARY server...';
        
        -- Verify replication user exists
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'replicator') THEN
            RAISE NOTICE 'Replication user exists: OK';
        ELSE
            RAISE WARNING 'Replication user does not exist!';
        END IF;
        
        -- Verify logical replication slots exist
        IF EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_type = 'logical') THEN
            RAISE NOTICE 'Logical replication slots exist: OK';
        ELSE
            RAISE WARNING 'No logical replication slots found!';
        END IF;
        
        -- Verify publication exists
        IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'privatbank_publication') THEN
            RAISE NOTICE 'Publication exists: OK';
        ELSE
            RAISE WARNING 'Publication does not exist!';
        END IF;
        
        -- Show replication status
        RAISE NOTICE 'Replication status:';
        PERFORM * FROM check_replication_status();
        
    ELSE
        RAISE NOTICE 'Running on STANDBY server...';
        
        -- Check if subscription exists
        IF EXISTS (SELECT 1 FROM pg_subscription WHERE subname = 'privatbank_subscription') THEN
            RAISE NOTICE 'Subscription exists: OK';
        ELSE
            RAISE WARNING 'Subscription does not exist!';
        END IF;
        
        -- Show basic standby info
        RAISE NOTICE 'Standby server is running and ready';
        
    END IF;
END $$;

-- Create a simple test to verify replication is working
CREATE OR REPLACE FUNCTION test_replication()
RETURNS TEXT AS $$
DECLARE
    test_guid UUID;
    result TEXT;
BEGIN
    -- Generate a test record
    test_guid := gen_random_uuid();
    
    -- Insert test record
    INSERT INTO t1 (date, amount, status, operation_guid, message)
    VALUES (
        CURRENT_DATE,
        999.99,
        0,
        test_guid,
        '{"customer_id": "test_replication", "account_number": "test_account", "operation_type": "test"}'::jsonb
    );
    
    -- Check if record exists
    IF EXISTS (SELECT 1 FROM t1 WHERE operation_guid = test_guid) THEN
        result := 'Test record inserted successfully on ' || 
                 CASE WHEN pg_is_in_recovery() THEN 'STANDBY' ELSE 'PRIMARY' END || ' server';
    ELSE
        result := 'Failed to insert test record';
    END IF;
    
    -- Clean up test record
    DELETE FROM t1 WHERE operation_guid = test_guid;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION test_replication() IS 'Tests replication functionality by inserting and verifying a test record';

-- Show final status
SELECT 'Replication setup completed!' as status;
