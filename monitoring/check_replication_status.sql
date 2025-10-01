-- PrivatBank Test Task - Check Replication Status Function
-- Function to check replication status from primary server

CREATE OR REPLACE FUNCTION check_replication_status()
RETURNS TABLE(
    server_type TEXT,
    metric_name TEXT,
    metric_value TEXT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Primary server replication status
    SELECT 
        'PRIMARY'::TEXT as server_type,
        'wal_senders'::TEXT as metric_name,
        (SELECT COUNT(*)::TEXT FROM pg_stat_replication) as metric_value,
        'Number of active WAL senders'::TEXT as description
    UNION ALL
    SELECT 
        'PRIMARY'::TEXT as server_type,
        'replication_slots'::TEXT as metric_name,
        (SELECT COUNT(*)::TEXT FROM pg_replication_slots) as metric_value,
        'Number of replication slots'::TEXT as description
    UNION ALL
    SELECT 
        'PRIMARY'::TEXT as server_type,
        'publications'::TEXT as metric_name,
        (SELECT COUNT(*)::TEXT FROM pg_publication) as metric_value,
        'Number of publications'::TEXT as description
    UNION ALL
    SELECT 
        'PRIMARY'::TEXT as server_type,
        'wal_level'::TEXT as metric_name,
        (SELECT setting FROM pg_settings WHERE name = 'wal_level') as metric_value,
        'WAL level configuration'::TEXT as description
    UNION ALL
    SELECT 
        'PRIMARY'::TEXT as server_type,
        'max_wal_senders'::TEXT as metric_name,
        (SELECT setting FROM pg_settings WHERE name = 'max_wal_senders') as metric_value,
        'Maximum WAL senders'::TEXT as description;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION check_replication_status() IS 'Returns replication status from primary server';

