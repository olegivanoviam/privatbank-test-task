-- PrivatBank Test Task - Job Management Functions
-- Functions for monitoring and managing jobs

-- Function to check job status and system statistics
CREATE OR REPLACE FUNCTION check_job_status()
RETURNS TABLE(
    metric TEXT,
    value BIGINT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'total_records'::TEXT as metric,
        (SELECT COUNT(*) FROM t1)::BIGINT as value,
        'Total records in t1 table'::TEXT as description
    UNION ALL
    SELECT 
        'pending_records'::TEXT as metric,
        (SELECT COUNT(*) FROM t1 WHERE status = 0)::BIGINT as value,
        'Records with status = 0 (pending)'::TEXT as description
    UNION ALL
    SELECT 
        'completed_records'::TEXT as metric,
        (SELECT COUNT(*) FROM t1 WHERE status = 1)::BIGINT as value,
        'Records with status = 1 (completed)'::TEXT as description
    UNION ALL
    SELECT 
        'records_last_hour'::TEXT as metric,
        (SELECT COUNT(*) FROM t1 WHERE created_at > NOW() - INTERVAL '1 hour')::BIGINT as value,
        'Records created in last hour'::TEXT as description
    UNION ALL
    SELECT 
        'materialized_view_rows'::TEXT as metric,
        (SELECT COUNT(*) FROM customer_totals)::BIGINT as value,
        'Rows in customer_totals materialized view'::TEXT as description;
END;
$$ LANGUAGE plpgsql;

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

-- Add comments
COMMENT ON FUNCTION check_job_status() IS 'Returns system statistics for PrivatBank test task';
COMMENT ON FUNCTION check_data_quality() IS 'Performs data quality checks for PrivatBank test task';
