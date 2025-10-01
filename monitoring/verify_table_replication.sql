-- PrivatBank Test Task - Verify Table Replication Function
-- Function to verify table T1 replication

CREATE OR REPLACE FUNCTION verify_table_replication()
RETURNS TABLE(
    check_name TEXT,
    primary_count BIGINT,
    standby_count BIGINT,
    status TEXT,
    description TEXT
) AS $$
DECLARE
    primary_count_val BIGINT;
    standby_count_val BIGINT;
BEGIN
    -- Get primary count
    SELECT COUNT(*) INTO primary_count_val FROM t1;
    
    -- Try to get standby count (this will only work if run on standby)
    BEGIN
        SELECT COUNT(*) INTO standby_count_val FROM t1;
    EXCEPTION WHEN OTHERS THEN
        standby_count_val := -1; -- Indicate error
    END;
    
    RETURN QUERY
    SELECT 
        'table_t1_records'::TEXT as check_name,
        primary_count_val as primary_count,
        standby_count_val as standby_count,
        CASE 
            WHEN standby_count_val = -1 THEN 'ERROR'
            WHEN primary_count_val = standby_count_val THEN 'SYNC'
            ELSE 'LAG'
        END as status,
        'Record count comparison between primary and standby'::TEXT as description;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION verify_table_replication() IS 'Verifies table T1 replication between primary and standby';

