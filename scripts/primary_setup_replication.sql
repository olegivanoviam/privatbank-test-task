-- PrivatBank Test Task - Primary Server Logical Replication Setup
-- Configuration for PostgreSQL logical replication

-- Create replication user
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';

-- Grant necessary permissions
GRANT CONNECT ON DATABASE privatebank_test TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO replicator;

-- Grant permissions on future tables and sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO replicator;

-- Logical replication slot will be created automatically by the subscription

-- Create publication for logical replication (for table T1 specifically)
CREATE PUBLICATION privatbank_publication FOR TABLE t1;

-- Add comment
COMMENT ON ROLE replicator IS 'Replication user for PrivatBank test task logical replication';
COMMENT ON PUBLICATION privatbank_publication IS 'Publication for PrivatBank table T1 logical replication';
