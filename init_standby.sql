-- PrivatBank Test Task - Standby Database Initialization
-- This script initializes the standby database for logical replication

-- ==============================================
-- STEP 1: CREATE DATABASE SCHEMA
-- ==============================================

-- Create the same table structure as primary
\i schema/standby/create_table_t1.sql

-- ==============================================
-- STEP 2: CREATE INDEXES
-- ==============================================

-- Create indexes to match primary structure
\i schema/standby/create_indexes.sql

-- ==============================================
-- STEP 3: SETUP REPLICATION
-- ==============================================

-- Set up replica identity for logical replication
\i schema/standby/setup_replication.sql

-- ==============================================
-- STEP 4: CREATE SUBSCRIPTION
-- ==============================================

-- Create subscription to primary
\i scripts/standby_setup_replication.sql

-- ==============================================
-- INITIALIZATION COMPLETE
-- ==============================================

SELECT 'Standby database initialization completed successfully!' as status;
SELECT 'Replication is ready!' as message;