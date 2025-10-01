-- PrivatBank Test Task - Check Standby Status Function
-- Function to check standby server status (run on standby)

CREATE OR REPLACE FUNCTION check_standby_status()
RETURNS TABLE(
    server_type TEXT,
    metric_name TEXT,
    metric_value TEXT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Standby server status
    SELECT 
        'STANDBY'::TEXT as server_type,
        'recovery_mode'::TEXT as metric_name,
        (SELECT CASE WHEN pg_is_in_recovery() THEN 'YES' ELSE 'NO' END) as metric_value,
        'Is server in recovery mode'::TEXT as description
    UNION ALL
    SELECT 
        'STANDBY'::TEXT as server_type,
        'primary_conninfo'::TEXT as metric_name,
        (SELECT setting FROM pg_settings WHERE name = 'primary_conninfo') as metric_value,
        'Primary connection info'::TEXT as description
    UNION ALL
    SELECT 
        'STANDBY'::TEXT as server_type,
        'primary_slot_name'::TEXT as metric_name,
        (SELECT setting FROM pg_settings WHERE name = 'primary_slot_name') as metric_value,
        'Primary replication slot name'::TEXT as description
    UNION ALL
    SELECT 
        'STANDBY'::TEXT as server_type,
        'hot_standby'::TEXT as metric_name,
        (SELECT setting FROM pg_settings WHERE name = 'hot_standby') as metric_value,
        'Hot standby enabled'::TEXT as description;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION check_standby_status() IS 'Returns standby server status (run on standby)';

