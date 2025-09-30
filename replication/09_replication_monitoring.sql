-- PrivatBank Test Task - Replication Monitoring Functions
-- Functions for monitoring and verifying replication status

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

-- Function to get replication lag information
CREATE OR REPLACE FUNCTION get_replication_lag()
RETURNS TABLE(
    client_addr INET,
    application_name TEXT,
    state TEXT,
    sent_lsn TEXT,
    write_lsn TEXT,
    flush_lsn TEXT,
    replay_lsn TEXT,
    write_lag INTERVAL,
    flush_lag INTERVAL,
    replay_lag INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.client_addr,
        r.application_name,
        r.state,
        r.sent_lsn::TEXT,
        r.write_lsn::TEXT,
        r.flush_lsn::TEXT,
        r.replay_lsn::TEXT,
        r.write_lag,
        r.flush_lag,
        r.replay_lag
    FROM pg_stat_replication r;
END;
$$ LANGUAGE plpgsql;

-- Add comments
COMMENT ON FUNCTION check_replication_status() IS 'Returns replication status from primary server';
COMMENT ON FUNCTION check_standby_status() IS 'Returns standby server status (run on standby)';
COMMENT ON FUNCTION verify_table_replication() IS 'Verifies table T1 replication between primary and standby';
COMMENT ON FUNCTION get_replication_lag() IS 'Returns detailed replication lag information';

