-- PrivatBank Test Task - Materialized View
-- Customer transaction totals by customer_id and operation_type
-- Shared materialized view for both primary and standby servers

-- Create materialized view for customer totals (as per task requirements)
CREATE MATERIALIZED VIEW IF NOT EXISTS customer_totals AS
SELECT 
    (message->>'customer_id')::INTEGER as customer_id,
    (message->>'operation_type')::TEXT as operation_type,
    SUM(amount) as total_amount
FROM t1
WHERE message->>'customer_id' IS NOT NULL
  AND message->>'customer_id' ~ '^[0-9]+$'  -- Ensure numeric customer_id
  AND message->>'operation_type' IS NOT NULL
  AND message->>'operation_type' IN ('online', 'offline')  -- Validate operation_type
GROUP BY (message->>'customer_id')::INTEGER, (message->>'operation_type')::TEXT
ORDER BY customer_id, operation_type;

-- Create indexes on materialized view (idempotent)
CREATE UNIQUE INDEX IF NOT EXISTS idx_customer_totals_customer_operation ON customer_totals (customer_id, operation_type);
CREATE INDEX IF NOT EXISTS idx_customer_totals_total_amount ON customer_totals (total_amount);

-- Add comments
COMMENT ON MATERIALIZED VIEW customer_totals IS 'Customer transaction totals by customer_id and operation_type for PrivatBank test task';
COMMENT ON COLUMN customer_totals.customer_id IS 'Customer identifier';
COMMENT ON COLUMN customer_totals.operation_type IS 'Operation type (online/offline)';
COMMENT ON COLUMN customer_totals.total_amount IS 'Total transaction amount';

-- Usage instructions:
-- To refresh the materialized view: REFRESH MATERIALIZED VIEW customer_totals;
-- To refresh concurrently (PostgreSQL 9.4+): REFRESH MATERIALIZED VIEW CONCURRENTLY customer_totals;
-- Note: Concurrent refresh requires a unique index (which we have)
