-- PrivatBank Test Task - Table T1 Schema
-- Partitioned table for transaction data

-- Create the main partitioned table
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

-- Replica identity setup is now in setup_replication.sql

-- Add comments
COMMENT ON TABLE t1 IS 'Partitioned transaction table for PrivatBank test task';
COMMENT ON COLUMN t1.date IS 'Transaction date (used for partitioning)';
COMMENT ON COLUMN t1.id IS 'Sequential transaction ID';
COMMENT ON COLUMN t1.amount IS 'Transaction amount';
COMMENT ON COLUMN t1.status IS 'Transaction status: 0=pending, 1=completed';
COMMENT ON COLUMN t1.operation_guid IS 'Unique identifier for each operation';
COMMENT ON COLUMN t1.message IS 'JSON message containing account number, customer id, and operation type';
COMMENT ON COLUMN t1.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN t1.updated_at IS 'Record last update timestamp';
