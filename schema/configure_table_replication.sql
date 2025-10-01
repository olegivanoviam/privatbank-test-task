-- PrivatBank Test Task - Table Replication Configuration
-- Configures tables and partitions for logical replication
-- Shared table replication configuration for both primary and standby servers

-- Set replica identity for logical replication (idempotent)
DO $$
BEGIN
    ALTER TABLE t1 REPLICA IDENTITY FULL;
    RAISE NOTICE 'Set REPLICA IDENTITY FULL for main table t1';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Could not set REPLICA IDENTITY FULL for t1: %', SQLERRM;
END $$;

-- Set replica identity for all partitions (idempotent)
DO $$
DECLARE
    partition_name TEXT;
    partitions_processed INTEGER := 0;
BEGIN
    FOR partition_name IN 
        SELECT schemaname||'.'||tablename 
        FROM pg_tables 
        WHERE tablename LIKE 't1_%' 
        AND schemaname = 'public'
    LOOP
        BEGIN
            EXECUTE 'ALTER TABLE ' || partition_name || ' REPLICA IDENTITY FULL';
            RAISE NOTICE 'Set REPLICA IDENTITY FULL for partition %', partition_name;
            partitions_processed := partitions_processed + 1;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Could not set REPLICA IDENTITY FULL for %: %', partition_name, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Processed % partitions for replica identity setup', partitions_processed;
END $$;

-- Verify replica identity setup
DO $$
DECLARE
    replica_identity TEXT;
    partition_count INTEGER;
BEGIN
    -- Check main table replica identity
    SELECT relreplident::text INTO replica_identity 
    FROM pg_class 
    WHERE relname = 't1' AND relkind = 'r';
    
    RAISE NOTICE 'Main table t1 replica identity: %', replica_identity;
    
    -- Count partitions with replica identity
    SELECT COUNT(*) INTO partition_count
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relname LIKE 't1_%' 
    AND n.nspname = 'public'
    AND c.relkind = 'r';
    
    RAISE NOTICE 'Found % partitions for replication', partition_count;
    
    IF replica_identity = 'f' THEN
        RAISE NOTICE 'Replication setup completed successfully';
    ELSE
        RAISE WARNING 'Replication setup may be incomplete';
    END IF;
END $$;
