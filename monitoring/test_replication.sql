-- PrivatBank Test Task - Test Replication Function
-- Function to test replication functionality and server capabilities

CREATE OR REPLACE FUNCTION test_replication()
RETURNS TEXT AS $$
DECLARE
    test_guid UUID;
    result TEXT;
    server_type TEXT;
    record_count INTEGER;
BEGIN
    -- Generate a unique test record ID
    test_guid := uuid_generate_v4();
    
    -- Determine server type more accurately for logical replication
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'privatbank_publication') THEN
        server_type := 'PRIMARY';
    ELSIF EXISTS (SELECT 1 FROM pg_subscription WHERE subname = 'privatbank_subscription') THEN
        server_type := 'STANDBY';
    ELSE
        server_type := 'UNKNOWN';
    END IF;
    
    -- Test INSERT operation
    BEGIN
        INSERT INTO t1 (date, amount, status, operation_guid, message)
        VALUES (
            CURRENT_DATE,
            999.99,
            0,
            test_guid,
            jsonb_build_object(
                'customer_id', '999999',
                'account_number', 'TEST_ACC_001',
                'operation_type', 'test'
            )
        );
        
        -- Verify record was inserted
        SELECT COUNT(*) INTO record_count FROM t1 WHERE operation_guid = test_guid;
        
        IF record_count > 0 THEN
            result := 'Test record inserted successfully on ' || server_type || ' server (ID: ' || test_guid || ')';
        ELSE
            result := 'Failed to verify test record insertion';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            result := 'Test failed on ' || server_type || ' server: ' || SQLERRM;
    END;
    
    -- Clean up test record
    BEGIN
        DELETE FROM t1 WHERE operation_guid = test_guid;
        RAISE NOTICE 'Test record cleaned up successfully';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'Failed to clean up test record: %', SQLERRM;
    END;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION test_replication() IS 'Tests replication functionality by inserting and verifying a test record on both primary and standby servers';
