-- PrivatBank Test Task - Standby Database Initialization
-- This script initializes the standby database for logical replication

-- ==============================================
-- STEP 1: CREATE DATABASE SCHEMA
-- ==============================================

-- Create the same table structure as primary
CREATE TABLE t1 (
    id BIGSERIAL,
    date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    operation_guid UUID NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (id, date)
) PARTITION BY RANGE (date);

-- Create partitions for 2024 (24 months)
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

-- ==============================================
-- STEP 2: CREATE INDEXES
-- ==============================================

-- Enable pg_trgm extension for GIN indexes
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create indexes to match primary structure
CREATE INDEX idx_t1_account_number ON t1 USING gin ((message ->> 'account_number') gin_trgm_ops);
CREATE INDEX idx_t1_amount ON t1 (amount);
CREATE INDEX idx_t1_created_at ON t1 (created_at);
CREATE INDEX idx_t1_customer_id ON t1 USING gin ((message ->> 'customer_id') gin_trgm_ops);
CREATE INDEX idx_t1_date ON t1 (date);
CREATE INDEX idx_t1_id ON t1 (id);
CREATE INDEX idx_t1_operation_type ON t1 USING gin ((message ->> 'operation_type') gin_trgm_ops);
CREATE INDEX idx_t1_status ON t1 (status);
CREATE INDEX idx_t1_updated_at ON t1 (updated_at);
CREATE UNIQUE INDEX uk_t1_operation_guid ON t1 (operation_guid, date);

-- ==============================================
-- STEP 3: SETUP REPLICATION
-- ==============================================

-- Set replica identity for logical replication
ALTER TABLE t1 REPLICA IDENTITY FULL;

-- Set replica identity for all partitions
DO $$
DECLARE
    partition_name TEXT;
BEGIN
    FOR partition_name IN 
        SELECT schemaname||'.'||tablename 
        FROM pg_tables 
        WHERE tablename LIKE 't1_%' 
        AND schemaname = 'public'
    LOOP
        BEGIN
            EXECUTE 'ALTER TABLE ' || partition_name || ' REPLICA IDENTITY FULL';
            RAISE NOTICE 'Set REPLICA IDENTITY FULL for %', partition_name;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Could not set REPLICA IDENTITY FULL for %: %', partition_name, SQLERRM;
        END;
    END LOOP;
END $$;

-- ==============================================
-- STEP 4: CREATE SUBSCRIPTION
-- ==============================================

-- Create subscription to primary
CREATE SUBSCRIPTION privatbank_subscription
CONNECTION 'host=postgres-primary port=5432 user=replicator password=replicator_password dbname=privatebank_test'
PUBLICATION privatbank_publication;

-- ==============================================
-- INITIALIZATION COMPLETE
-- ==============================================

SELECT 'Standby database initialization completed successfully!' as status;
SELECT 'Replication is ready!' as message;
