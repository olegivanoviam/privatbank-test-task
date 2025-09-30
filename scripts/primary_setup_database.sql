-- PrivatBank Test Task - Database Setup Script
-- This script sets up the complete database schema and initial data

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- The Docker entrypoint will automatically execute all .sql files in docker-entrypoint-initdb.d
-- So we just need to generate initial data and refresh the materialized view

-- Generate initial test data (100k records)
DO $$
BEGIN
    PERFORM generate_test_data(100000, 1000);
    RAISE NOTICE 'Generated 100,000 test records successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Failed to generate test data: %', SQLERRM;
END $$;

-- Refresh materialized view
DO $$
BEGIN
    REFRESH MATERIALIZED VIEW customer_totals;
    RAISE NOTICE 'Materialized view customer_totals refreshed successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Failed to refresh materialized view: %', SQLERRM;
END $$;

-- Display completion message
SELECT 'PrivatBank Test Task - Database Setup Complete!' as message;
