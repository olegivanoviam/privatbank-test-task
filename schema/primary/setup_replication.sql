-- PrivatBank Test Task - Primary Replication Setup
-- Sets up replica identity for logical replication

-- Set replica identity for logical replication
ALTER TABLE t1 REPLICA IDENTITY FULL;

-- Set replica identity for all partition tables (required for logical replication)
DO $$
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE tablename LIKE 't1_%') 
    LOOP 
        BEGIN
            EXECUTE 'ALTER TABLE ' || r.tablename || ' REPLICA IDENTITY FULL;';
            RAISE NOTICE 'Set replica identity for partition: %', r.tablename;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Failed to set replica identity for %: %', r.tablename, SQLERRM;
        END;
    END LOOP;
END $$;
