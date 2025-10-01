-- PrivatBank Test Task - Check Job Status Function
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

-- Add comment
COMMENT ON FUNCTION check_job_status() IS 'Returns system statistics for PrivatBank test task';

