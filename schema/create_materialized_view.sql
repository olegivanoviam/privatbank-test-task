-- PrivatBank Test Task - Materialized View
-- Customer transaction totals with automatic refresh
-- Shared materialized view for both primary and standby servers

-- Create materialized view for customer totals by customer_id and operation_type
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

-- Create index on materialized view
CREATE UNIQUE INDEX idx_customer_totals_customer_operation ON customer_totals (customer_id, operation_type);
CREATE INDEX idx_customer_totals_total_amount ON customer_totals (total_amount);
CREATE INDEX idx_customer_totals_transaction_count ON customer_totals (transaction_count);

-- Add comments
COMMENT ON MATERIALIZED VIEW customer_totals IS 'Customer transaction totals by customer_id and operation_type for PrivatBank test task';
COMMENT ON COLUMN customer_totals.customer_id IS 'Customer identifier';
COMMENT ON COLUMN customer_totals.operation_type IS 'Operation type (online/offline)';
COMMENT ON COLUMN customer_totals.transaction_count IS 'Total number of transactions';
COMMENT ON COLUMN customer_totals.total_amount IS 'Total transaction amount';
COMMENT ON COLUMN customer_totals.avg_amount IS 'Average transaction amount';
COMMENT ON COLUMN customer_totals.first_transaction IS 'First transaction timestamp';
COMMENT ON COLUMN customer_totals.last_transaction IS 'Last transaction timestamp';
COMMENT ON COLUMN customer_totals.completed_transactions IS 'Number of completed transactions';
COMMENT ON COLUMN customer_totals.pending_transactions IS 'Number of pending transactions';
