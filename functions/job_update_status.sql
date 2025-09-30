-- PrivatBank Test Task - Job Update Status Function
-- Job to update transaction status based on even/odd id

CREATE OR REPLACE FUNCTION job_update_status()
RETURNS VOID AS $$
DECLARE
    updated_count INTEGER;
    current_second INTEGER;
BEGIN
    -- Get current second
    current_second := EXTRACT(SECOND FROM NOW())::INTEGER;
    
    -- Update status based on even/odd second and id
    IF current_second % 2 = 0 THEN
        -- Even second: update even ids from 0 to 1
        UPDATE t1 
        SET status = 1, updated_at = NOW()
        WHERE status = 0 
        AND id % 2 = 0;
        
        GET DIAGNOSTICS updated_count = ROW_COUNT;
        
        IF updated_count > 0 THEN
            RAISE NOTICE 'Updated % even ID transactions from pending to completed', updated_count;
        END IF;
    ELSE
        -- Odd second: update odd ids from 0 to 1
        UPDATE t1 
        SET status = 1, updated_at = NOW()
        WHERE status = 0 
        AND id % 2 = 1;
        
        GET DIAGNOSTICS updated_count = ROW_COUNT;
        
        IF updated_count > 0 THEN
            RAISE NOTICE 'Updated % odd ID transactions from pending to completed', updated_count;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION job_update_status() IS 'Scheduled job to update transaction status for PrivatBank test task';

