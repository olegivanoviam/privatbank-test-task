-- PrivatBank Test Task - Test Replication Function
-- Function to test replication functionality

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
