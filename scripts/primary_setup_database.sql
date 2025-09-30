-- PrivatBank Test Task - Database Setup Script
-- This script sets up the complete database schema and initial data

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- The Docker entrypoint will automatically execute all .sql files in docker-entrypoint-initdb.d
-- So we just need to generate initial data and refresh the materialized view

-- Generate initial test data (100k records)
SELECT generate_test_data(100000, 1000);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW customer_totals;

-- Replica identity for partitions is now set in create_table_t1.sql

-- Display completion message
SELECT 'PrivatBank Test Task - Database Setup Complete!' as message;
