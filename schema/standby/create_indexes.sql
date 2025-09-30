-- PrivatBank Test Task - Standby Indexes Creation
-- Creates indexes to match primary structure

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
