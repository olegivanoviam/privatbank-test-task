-- PrivatBank Test Task - Standby Database Initialization
-- This script initializes the standby database for logical replication
-- NOTE: Table structure must be IDENTICAL to primary for logical replication

-- ==============================================
-- STEP 1: CREATE DATABASE SCHEMA (IDENTICAL TO PRIMARY)
-- ==============================================

-- Create the EXACT same table structure as primary
\i schema/create_table_t1.sql

-- ==============================================
-- STEP 2: SETUP REPLICATION
-- ==============================================

-- Configure table for logical replication
\i schema/configure_table_replication.sql

-- ==============================================
-- STEP 3: CREATE SUBSCRIPTION
-- ==============================================

-- Create subscription to primary
\i scripts/standby_setup_replication.sql

-- ==============================================
-- INITIALIZATION COMPLETE
-- ==============================================

SELECT 'Standby database initialization completed successfully!' as status;
SELECT 'Replication is ready!' as message;