-- PrivatBank Test Task - Materialized View Refresh
-- Function to refresh the customer_totals materialized view

CREATE OR REPLACE FUNCTION refresh_customer_totals()
RETURNS VOID AS $$
BEGIN
    -- Refresh materialized view concurrently if possible
    BEGIN
        REFRESH MATERIALIZED VIEW CONCURRENTLY customer_totals;
    EXCEPTION
        WHEN OTHERS THEN
            -- Fallback to regular refresh if concurrent is not possible
            REFRESH MATERIALIZED VIEW customer_totals;
    END;
    
    RAISE NOTICE 'Materialized view customer_totals refreshed at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to auto-refresh materialized view on status change
CREATE OR REPLACE FUNCTION trigger_refresh_customer_totals()
RETURNS TRIGGER AS $$
BEGIN
    -- Only refresh if status changed from 0 to 1
    IF OLD.status = 0 AND NEW.status = 1 THEN
        PERFORM refresh_customer_totals();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on t1 table
DROP TRIGGER IF EXISTS trg_refresh_customer_totals ON t1;
CREATE TRIGGER trg_refresh_customer_totals
    AFTER UPDATE ON t1
    FOR EACH ROW
    EXECUTE FUNCTION trigger_refresh_customer_totals();

-- Add comments
COMMENT ON FUNCTION refresh_customer_totals() IS 'Refreshes the customer_totals materialized view for PrivatBank test task';
COMMENT ON FUNCTION trigger_refresh_customer_totals() IS 'Trigger function to auto-refresh materialized view on status changes from 0 to 1';