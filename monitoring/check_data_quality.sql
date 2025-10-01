-- PrivatBank Test Task - Check Data Quality Function
-- Function to check data quality

CREATE OR REPLACE FUNCTION check_data_quality()
RETURNS TABLE(
    check_name TEXT,
    result TEXT,
    details TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'duplicate_guids'::TEXT as check_name,
        CASE WHEN (SELECT COUNT(*) FROM (
            SELECT operation_guid, date, COUNT(*) 
            FROM t1 
            GROUP BY operation_guid, date 
            HAVING COUNT(*) > 1
        ) t) > 0 THEN 'FAIL' ELSE 'PASS' END as result,
        'Check for duplicate operation_guid within same date'::TEXT as details
    UNION ALL
    SELECT 
        'null_customer_ids'::TEXT as check_name,
        CASE WHEN (SELECT COUNT(*) FROM t1 WHERE message->>'customer_id' IS NULL) > 0 
        THEN 'FAIL' ELSE 'PASS' END as result,
        'Check for null customer_id in message'::TEXT as details
    UNION ALL
    SELECT 
        'invalid_amounts'::TEXT as check_name,
        CASE WHEN (SELECT COUNT(*) FROM t1 WHERE (message->>'amount')::NUMERIC <= 0) > 0 
        THEN 'FAIL' ELSE 'PASS' END as result,
        'Check for invalid amounts (<= 0)'::TEXT as details
    UNION ALL
    SELECT 
        'future_dates'::TEXT as check_name,
        CASE WHEN (SELECT COUNT(*) FROM t1 WHERE date > CURRENT_DATE) > 0 
        THEN 'FAIL' ELSE 'PASS' END as result,
        'Check for future dates'::TEXT as details;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION check_data_quality() IS 'Performs data quality checks for PrivatBank test task';

