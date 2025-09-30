-- PrivatBank Test Task - Primary Replication Setup
-- Sets up replica identity for logical replication

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

