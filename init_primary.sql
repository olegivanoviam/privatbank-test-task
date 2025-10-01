-- PrivatBank Test Task - Primary Database Initialization
-- This script initializes the primary database with all required components

-- ==============================================
-- STEP 1: CREATE DATABASE SCHEMA
-- ==============================================

-- Create the main partitioned table T1
\i schema/primary/create_table_t1.sql

-- Create materialized view (depends on table T1)
\i schema/primary/create_materialized_view.sql

-- Setup replication for table T1
\i schema/primary/setup_replication.sql

-- ==============================================
-- STEP 2: CREATE FUNCTIONS
-- ==============================================

-- Create data generation function
\i functions/generate_test_data.sql

-- Create scheduled job functions
\i functions/job_insert_transaction.sql
\i functions/job_update_status.sql

-- Create job management functions
\\i monitoring/check_job_status.sql
\\i monitoring/check_data_quality.sql

-- ==============================================
-- STEP 3: SETUP DATA AND REPLICATION
-- ==============================================

-- Generate test data and setup database
\i scripts/primary_setup_database.sql

-- Setup primary server for logical replication
\i scripts/primary_setup_replication.sql

-- ==============================================
-- STEP 4: MONITORING AND VERIFICATION
-- ==============================================

-- Create replication monitoring functions
\\i monitoring/check_replication_status.sql
\\i monitoring/check_standby_status.sql
\\i monitoring/verify_table_replication.sql
\\i monitoring/get_replication_lag.sql

-- Create test replication function
\\i monitoring/test_replication.sql

-- Verify replication setup
\i scripts/verify_replication_status.sql

-- ==============================================
-- INITIALIZATION COMPLETE
-- ==============================================

SELECT 'Primary database initialization completed successfully!' as status;
SELECT 'All tables, functions, and replication are ready!' as message;
