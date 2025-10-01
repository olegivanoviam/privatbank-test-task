-- PrivatBank Test Task - Primary Server Logical Replication Setup
-- Configuration for PostgreSQL logical replication

-- Create replication user (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'replicator') THEN
        CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';
        RAISE NOTICE 'Replication user "replicator" created successfully';
    ELSE
        RAISE NOTICE 'Replication user "replicator" already exists';
    END IF;
END
$$;

-- Grant necessary permissions (idempotent)
GRANT CONNECT ON DATABASE privatbank_test TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO replicator;

-- Grant permissions on future tables and sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO replicator;

-- Logical replication slot will be created automatically by the subscription

-- Create publication for logical replication (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_publication WHERE pubname = 'privatbank_publication') THEN
        CREATE PUBLICATION privatbank_publication FOR TABLE t1;
        RAISE NOTICE 'Publication "privatbank_publication" created successfully';
    ELSE
        RAISE NOTICE 'Publication "privatbank_publication" already exists';
    END IF;
END
$$;

-- Add comments
COMMENT ON ROLE replicator IS 'Replication user for PrivatBank test task logical replication';
COMMENT ON PUBLICATION privatbank_publication IS 'Publication for PrivatBank table T1 logical replication';

-- Verify replication setup
DO $$
DECLARE
    user_exists BOOLEAN;
    pub_exists BOOLEAN;
BEGIN
    -- Check if replication user exists
    SELECT EXISTS(SELECT FROM pg_roles WHERE rolname = 'replicator') INTO user_exists;
    
    -- Check if publication exists
    SELECT EXISTS(SELECT FROM pg_publication WHERE pubname = 'privatbank_publication') INTO pub_exists;
    
    -- Report status
    IF user_exists AND pub_exists THEN
        RAISE NOTICE 'Replication setup completed successfully';
        RAISE NOTICE 'User: replicator, Publication: privatbank_publication';
    ELSE
        RAISE WARNING 'Replication setup may be incomplete. User: %, Publication: %', user_exists, pub_exists;
    END IF;
END
$$;
