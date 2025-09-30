-- PrivatBank Test Task - Logical Standby Initialization
-- This script sets up logical replication subscription for table T1

-- Wait for primary server to be ready
DO $$
BEGIN
    -- Wait for primary to be available
    PERFORM pg_sleep(5);
    RAISE NOTICE 'Setting up logical replication subscription...';
END $$;

-- Create the same table structure as primary (required for logical replication)
CREATE TABLE t1 (
    date DATE NOT NULL,
    id BIGSERIAL,
    amount NUMERIC(15,2) NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    operation_guid UUID NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uk_t1_operation_guid UNIQUE (operation_guid, date)
) PARTITION BY RANGE (date);

-- Create partitions for 2024 (12 months)
CREATE TABLE t1_2024_01 PARTITION OF t1 FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE t1_2024_02 PARTITION OF t1 FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
CREATE TABLE t1_2024_03 PARTITION OF t1 FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
CREATE TABLE t1_2024_04 PARTITION OF t1 FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
CREATE TABLE t1_2024_05 PARTITION OF t1 FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
CREATE TABLE t1_2024_06 PARTITION OF t1 FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
CREATE TABLE t1_2024_07 PARTITION OF t1 FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
CREATE TABLE t1_2024_08 PARTITION OF t1 FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
CREATE TABLE t1_2024_09 PARTITION OF t1 FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
CREATE TABLE t1_2024_10 PARTITION OF t1 FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
CREATE TABLE t1_2024_11 PARTITION OF t1 FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
CREATE TABLE t1_2024_12 PARTITION OF t1 FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');

-- Create partitions for 2025 (12 months)
CREATE TABLE t1_2025_01 PARTITION OF t1 FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE t1_2025_02 PARTITION OF t1 FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE t1_2025_03 PARTITION OF t1 FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE t1_2025_04 PARTITION OF t1 FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE t1_2025_05 PARTITION OF t1 FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE t1_2025_06 PARTITION OF t1 FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE t1_2025_07 PARTITION OF t1 FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE t1_2025_08 PARTITION OF t1 FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE t1_2025_09 PARTITION OF t1 FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE t1_2025_10 PARTITION OF t1 FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE t1_2025_11 PARTITION OF t1 FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE t1_2025_12 PARTITION OF t1 FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- Create indexes for performance
CREATE INDEX idx_t1_date ON t1 (date);
CREATE INDEX idx_t1_id ON t1 (id);
CREATE INDEX idx_t1_amount ON t1 (amount);
CREATE INDEX idx_t1_status ON t1 (status);
CREATE INDEX idx_t1_created_at ON t1 (created_at);
CREATE INDEX idx_t1_updated_at ON t1 (updated_at);

-- Enable pg_trgm extension for trigram indexes
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create GIN indexes for JSONB fields
CREATE INDEX idx_t1_customer_id ON t1 USING GIN ((message->>'customer_id') gin_trgm_ops);
CREATE INDEX idx_t1_account_number ON t1 USING GIN ((message->>'account_number') gin_trgm_ops);
CREATE INDEX idx_t1_operation_type ON t1 USING GIN ((message->>'operation_type') gin_trgm_ops);

-- Set replica identity for logical replication
ALTER TABLE t1 REPLICA IDENTITY FULL;

-- Set replica identity for all partition tables
DO $$
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE tablename LIKE 't1_%') 
    LOOP 
        EXECUTE 'ALTER TABLE ' || r.tablename || ' REPLICA IDENTITY FULL;';
        RAISE NOTICE 'Set replica identity for partition: %', r.tablename;
    END LOOP;
END $$;

-- Create materialized view (same as primary)
CREATE MATERIALIZED VIEW customer_totals AS
SELECT 
    (message->>'customer_id')::INTEGER as customer_id,
    (message->>'operation_type')::TEXT as operation_type,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount,
    MIN(created_at) as first_transaction,
    MAX(created_at) as last_transaction,
    COUNT(CASE WHEN status = 1 THEN 1 END) as completed_transactions,
    COUNT(CASE WHEN status = 0 THEN 1 END) as pending_transactions
FROM t1
WHERE message->>'customer_id' IS NOT NULL
  AND message->>'operation_type' IS NOT NULL
GROUP BY (message->>'customer_id')::INTEGER, (message->>'operation_type')::TEXT
ORDER BY customer_id, operation_type;

-- Create indexes on materialized view
CREATE UNIQUE INDEX idx_customer_totals_customer_operation ON customer_totals (customer_id, operation_type);
CREATE INDEX idx_customer_totals_total_amount ON customer_totals (total_amount);
CREATE INDEX idx_customer_totals_transaction_count ON customer_totals (transaction_count);

-- Wait a bit more for primary to be fully ready
DO $$
BEGIN
    PERFORM pg_sleep(10);
    RAISE NOTICE 'Primary should be ready, creating subscription...';
END $$;

-- Create logical replication subscription
CREATE SUBSCRIPTION privatbank_subscription
CONNECTION 'host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatebank_test'
PUBLICATION privatbank_publication;

-- Add comments
COMMENT ON TABLE t1 IS 'Replicated table T1 from primary server';
COMMENT ON SUBSCRIPTION privatbank_subscription IS 'Logical replication subscription for table T1';

-- Show completion message
SELECT 'Logical standby setup completed!' as status;
