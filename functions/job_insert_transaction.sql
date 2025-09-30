-- PrivatBank Test Task - Job Insert Transaction Function
-- Job to insert new transactions

CREATE OR REPLACE FUNCTION job_insert_transaction()
RETURNS VOID AS $$
DECLARE
    customer_id INTEGER;
    account_number TEXT;
    amount NUMERIC(15,2);
    operation_type TEXT;
    message_json JSONB;
    random_date DATE;
BEGIN
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
    
    -- Generate random date within last 30 days
    random_date := CURRENT_DATE - (RANDOM() * 30)::INTEGER;
    
    -- Create message JSON with required fields
    message_json := jsonb_build_object(
        'account_number', account_number,
        'customer_id', customer_id,
        'operation_type', operation_type
    );
    
    -- Insert new transaction with proper field order
    INSERT INTO t1 (date, amount, status, operation_guid, message)
    VALUES (
        random_date,
        amount,
        0, -- Start as pending
        uuid_generate_v4(),
        message_json
    );
    
    -- Log the insertion
    RAISE NOTICE 'Inserted new transaction for customer % with amount % (type: %)', customer_id, amount, operation_type;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION job_insert_transaction() IS 'Scheduled job to insert new transactions for PrivatBank test task';

