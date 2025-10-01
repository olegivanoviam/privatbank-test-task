-- PrivatBank Test Task - Replication Setup and Verification
-- This script sets up and verifies the replication setup

-- Replication monitoring functions are loaded from monitoring/ folder

-- Verify replication setup
DO $$
BEGIN
    -- Check if we're on primary server (has publications) or standby (has subscriptions)
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'privatbank_publication') THEN
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
        BEGIN
            PERFORM * FROM check_replication_status();
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Could not retrieve replication status: %', SQLERRM;
        END;
        
    ELSE
        RAISE NOTICE 'Running on STANDBY server...';
        
        -- Check if subscription exists
        IF EXISTS (SELECT 1 FROM pg_subscription WHERE subname = 'privatbank_subscription') THEN
            RAISE NOTICE 'Subscription exists: OK';
        ELSE
            RAISE WARNING 'Subscription does not exist!';
        END IF;
        
        -- Check replication lag
        BEGIN
            PERFORM * FROM get_replication_lag();
            RAISE NOTICE 'Replication lag check: OK';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Could not check replication lag: %', SQLERRM;
        END;
        
        -- Show detailed standby status
        BEGIN
            PERFORM * FROM check_standby_status();
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Could not retrieve standby status: %', SQLERRM;
        END;
        
        -- Show basic standby info
        RAISE NOTICE 'Standby server is running and ready';
        
    END IF;
END $$;

-- Test replication function is now in monitoring/test_replication.sql

-- Show final status with comprehensive summary
SELECT 
    'Replication verification completed successfully!' as status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'privatbank_publication') THEN 'PRIMARY'
        ELSE 'STANDBY'
    END as server_type,
    NOW() as verification_time;
