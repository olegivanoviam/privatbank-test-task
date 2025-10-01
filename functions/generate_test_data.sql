-- PrivatBank Test Task - Data Generation Function
-- Generates test data for the t1 table using simple single loop

CREATE OR REPLACE FUNCTION generate_test_data(
    num_records INTEGER DEFAULT 100000
) RETURNS VOID AS $$
DECLARE
    i INTEGER;
    random_date DATE;
    customer_id INTEGER;
    account_number TEXT;
    amount NUMERIC(15,2);
    operation_type TEXT;
    message_json JSONB;
BEGIN
    RAISE NOTICE 'Generating % records...', num_records;
    
    -- Generate data in single loop
    FOR i IN 1..num_records LOOP
        -- Generate random date within last 120 days
        random_date := CURRENT_DATE - (RANDOM() * 120)::INTEGER;
        
        -- Generate customer ID (1-1000)
        customer_id := (RANDOM() * 1000)::INTEGER + 1;
        
        -- Generate account number
        account_number := 'ACC_' || LPAD((RANDOM() * 999999)::INTEGER::TEXT, 6, '0');
        
        -- Generate amount (10-10000)
        amount := ROUND((RANDOM() * 9990 + 10)::NUMERIC, 2);
        
        -- Generate operation type (online/offline)
        operation_type := CASE (RANDOM() * 2)::INTEGER
            WHEN 0 THEN 'online'
            ELSE 'offline'
        END;
        
        -- Create message JSON with required fields
        message_json := jsonb_build_object(
            'account_number', account_number,
            'customer_id', customer_id,
            'operation_type', operation_type
        );
        
        -- Insert record with proper field order
        INSERT INTO t1 (date, amount, status, operation_guid, message)
        VALUES (
            random_date,
            amount,
            0, -- All start as pending
            uuid_generate_v4(),
            message_json
        );
        
        -- Progress reporting every 10000 records
        IF i % 10000 = 0 THEN
            RAISE NOTICE 'Generated % records...', i;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Data generation complete! Generated % records', num_records;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION generate_test_data(INTEGER, INTEGER) IS 'Generates test data for PrivatBank test task';