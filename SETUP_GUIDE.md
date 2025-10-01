# PrivatBank Test Task - Complete Setup Guide

> **Ready-to-run PostgreSQL solution with logical replication and automated jobs**

## 🚀 Quick Start (5 minutes)

### Prerequisites
- **Docker Desktop** installed and running
- **4GB RAM** minimum
- **2GB disk space**
- **Git** (optional, for cloning)

### Option 1: Automated Setup (Recommended)
```bash
# Clone the repository
git clone https://github.com/olegivanoviam/privatbank-test-task.git
cd privatbank-test-task

# Run automated setup (Linux/Mac)
./run_solution.sh

# Or run automated setup (Windows)
run_solution.bat

# For cold start (cleanup + restart)
./run_solution.sh --cold        # Linux/Mac
run_solution.bat --cold         # Windows
```

### Option 2: Manual Setup
```bash
# Clone the repository
git clone https://github.com/olegivanoviam/privatbank-test-task.git
cd privatbank-test-task

# Start the system
docker-compose up -d

# Verify everything is running
docker-compose ps
```

## ✅ Verification Steps

### 1. Check Services Status
```bash
docker-compose ps
```
**Expected Output:**
```
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                        PORTS                                         NAMES
xxxxxxxxxxxxx   postgres:15   "docker-entrypoint.s…"   X minutes ago    Up X minutes (healthy)        0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp   privatbank_postgres_primary
xxxxxxxxxxxxx   postgres:15   "docker-entrypoint.s…"   X minutes ago    Up X minutes (healthy)        0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp   privatbank_postgres_standby
xxxxxxxxxxxxx   postgres:15   "docker-entrypoint.s…"   X minutes ago    Up X minutes                  5432/tcp                                      privatbank_scheduler
```

### 2. Verify Database Records
```bash
# Check primary database records
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"

# Check standby database records
docker exec privatbank_postgres_standby psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"
```
**Expected:** Both should show 100,000+ records

### 3. Check Replication Status
```bash
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"
```
**Expected:** Shows active WAL senders and replication slots

### 4. Verify Jobs are Running
```bash
docker logs privatbank_scheduler --tail=10
```
**Expected:** Shows insert and update jobs running every 5s and 3s

## 🔧 Management Commands

### Database Access
```bash
# Connect to primary database
docker exec -it privatbank_postgres_primary psql -U postgres -d privatbank_test

# Connect to standby database
docker exec -it privatbank_postgres_standby psql -U postgres -d privatbank_test
```

### Monitoring
```bash
# Check replication status
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"

# Check data counts
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"
docker exec privatbank_postgres_standby psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"

# Check job status
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_job_status();"

# Check data quality
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_data_quality();"
```

### System Control
```bash
# Start system
docker-compose up -d

# Stop system
docker-compose down

# View logs
docker-compose logs

# Restart services
docker-compose restart

# Complete reset (removes all data)
docker-compose down -v && docker-compose up -d

# Cold start (cleanup + restart)
./run_solution.sh --cold        # Linux/Mac
run_solution.bat --cold         # Windows
```

## 🔄 Reliability Features

### Retry Logic with Exponential Backoff
The solution includes robust retry logic for reliable replication setup:

- **Exponential Backoff**: Delays increase exponentially (1s, 2s, 4s, 8s...)
- **Jitter**: Random variation to prevent thundering herd
- **Max Retries**: 15 attempts with up to 30-second delays
- **Automatic Recovery**: Handles timing issues during container startup

### Health Checks
- **Primary Health Check**: Verifies PostgreSQL readiness and publication existence
- **Standby Health Check**: Ensures standby is ready for connections
- **Dependency Management**: Standby waits for primary to be healthy

### Error Handling
- **Graceful Degradation**: System continues even if some checks fail
- **Detailed Logging**: Clear error messages and status updates
- **Recovery Instructions**: Helpful troubleshooting guidance

## 📊 Test Task Requirements Verification

### ✅ All Requirements Implemented:

1. **✅ Partitioned table T1** - Monthly partitions by date
2. **✅ 100k+ test data** - Generated over 3-4 months  
3. **✅ Unique operation_guid** - UUID constraint
4. **✅ Scheduled insert job** - Every 5 seconds, status=0
5. **✅ Scheduled update job** - Every 3 seconds, even/odd pattern
6. **✅ Materialized view** - Customer totals with automatic refresh
7. **✅ Logical replication** - Table T1 replicated to standby instance

### 🧪 Testing Commands

```bash
# Test 1: Verify table structure
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "\d t1"

# Test 2: Check partitions
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT schemaname, tablename FROM pg_tables WHERE tablename LIKE 't1_%' ORDER BY tablename;"

# Test 3: Verify materialized view
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM customer_totals LIMIT 5;"

# Test 4: Check replication sync
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM verify_table_replication();"

# Test 5: Monitor job execution
docker logs privatbank_scheduler --tail=20
```

## 🚨 Troubleshooting

### Common Issues

#### Services won't start
```bash
# Check Docker Desktop is running
docker --version

# Check logs for errors
docker-compose logs

# Restart everything
docker-compose down && docker-compose up -d
```

#### Database connection issues
```bash
# Check if databases are ready
docker exec privatbank_postgres_primary pg_isready -U postgres
docker exec privatbank_postgres_standby pg_isready -U postgres
```

#### Replication not working
```bash
# Check replication status
docker exec privatbank_postgres_primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"

# Check subscription status
docker exec privatbank_postgres_standby psql -U postgres -d privatbank_test -c "SELECT * FROM pg_subscription;"

# Check retry logic logs
docker logs privatbank_postgres_standby | grep -E "\[INFO\]|\[SUCCESS\]|\[WARNING\]|\[ERROR\]"
```

### Reset Everything
```bash
# Complete reset (removes all data)
docker-compose down -v
docker system prune -f
docker-compose up -d
```

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify Docker Desktop is running
3. Ensure you have sufficient resources (4GB RAM)
4. Try a complete reset if problems persist

## 📁 Project Structure

```
privatbank-test-task/
├── docker-compose.yml                    # Main orchestration
├── schema/                              # Shared database schema
│   ├── create_table_t1.sql              # Partitioned table definition
│   ├── create_materialized_view.sql     # Customer totals view
│   └── configure_table_replication.sql  # Replication setup
├── functions/                           # Core PostgreSQL functions
│   ├── generate_test_data.sql           # Data generation function
│   ├── job_insert_transaction.sql       # Insert job function
│   ├── job_update_status.sql            # Update job function
│   └── refresh_materialized_view.sql    # MV refresh function
├── monitoring/                          # Monitoring functions
│   ├── check_data_quality.sql           # Data quality checks
│   ├── check_job_status.sql             # Job status monitoring
│   ├── check_replication_status.sql     # Replication health
│   ├── check_standby_status.sql         # Standby monitoring
│   ├── get_replication_lag.sql          # Lag measurement
│   ├── test_replication.sql             # Replication testing
│   └── verify_table_replication.sql     # Table replication check
├── scripts/                             # All scripts and initialization files
│   ├── init_primary.sql                 # Primary database initialization
│   ├── init_standby.sql                 # Standby database initialization
│   ├── scheduler.sh                     # Job scheduler script
│   ├── primary_health_check.sh          # Primary health check
│   ├── create_subscription_with_retry.sh # Retry logic for subscription
│   ├── standby_entrypoint.sh            # Custom standby entrypoint
│   ├── primary_setup_database.sql       # Primary data setup
│   ├── primary_setup_replication.sql    # Primary replication setup
│   ├── standby_setup_replication.sql    # Standby subscription
│   └── verify_replication_status.sql    # Replication verification
├── run_solution.sh                      # Linux/Mac startup script
├── run_solution.bat                     # Windows startup script
├── test_solution.sh                     # Linux/Mac test script
├── test_solution.bat                    # Windows test script
├── README.md                            # Project documentation
├── SETUP_GUIDE.md                       # This file
└── TASK_DESCRIPTION.md                  # Task requirements
```

---

**Built with ❤️ using PostgreSQL, Docker, and Logical Replication**
