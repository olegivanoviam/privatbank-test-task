-- PrivatBank Test Task - Get Replication Lag Function
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

-- Add comment
COMMENT ON FUNCTION get_replication_lag() IS 'Returns detailed replication lag information';

