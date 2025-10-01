-- PrivatBank Test Task - Materialized View Refresh Function
-- Dedicated function to refresh the customer_totals materialized view
-- Can be called from triggers, jobs, or manually

CREATE OR REPLACE FUNCTION refresh_materialized_view()
RETURNS VOID AS $$
BEGIN
    -- Refresh the customer_totals materialized view
    REFRESH MATERIALIZED VIEW customer_totals;
    
    -- Log the refresh operation
    RAISE NOTICE 'Materialized view customer_totals refreshed successfully';
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION refresh_materialized_view() IS 'Refreshes the customer_totals materialized view for PrivatBank test task';
