-- PrivatBank Test Task - Primary Database Initialization
-- This script initializes the primary database with all required components

-- ==============================================
-- STEP 1: CREATE DATABASE SCHEMA
-- ==============================================

-- Create the main partitioned table T1
\i schemas/create_table_t1.sql

-- Create materialized view (depends on table T1)
\i schemas/create_materialized_view.sql

-- ==============================================
-- STEP 2: CREATE FUNCTIONS
-- ==============================================

-- Create data generation function
\i functions/generate_test_data.sql

-- Create scheduled job functions
\i jobs/scheduled_jobs.sql

-- Create job management functions
\i jobs/job_management.sql

-- ==============================================
-- STEP 3: SETUP DATA AND REPLICATION
-- ==============================================

-- Generate test data and setup database
\i scripts/setup_database.sql

-- Setup primary server for logical replication
\i replication/primary_setup_logical.sql

-- ==============================================
-- STEP 4: MONITORING AND VERIFICATION
-- ==============================================

-- Create replication monitoring functions
\i replication/replication_monitoring.sql

-- Verify replication setup
\i scripts/replication_setup.sql

-- ==============================================
-- INITIALIZATION COMPLETE
-- ==============================================

SELECT 'Primary database initialization completed successfully!' as status;
SELECT 'All tables, functions, and replication are ready!' as message;
