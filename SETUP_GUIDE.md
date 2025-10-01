# PrivatBank Test Task - Complete Setup Guide

> **Ready-to-run PostgreSQL solution with logical replication and automated jobs**

## 🚀 Quick Start (5 minutes)

### Prerequisites
- **Docker Desktop** installed and running
- **4GB RAM** minimum
- **2GB disk space**
- **Git** (optional, for cloning)

### Option 1: Run from Git Repository
```bash
# Clone the repository
git clone https://github.com/olegivanoviam/privatbank-test-task.git
cd privatbank-test-task

# Start the system
docker-compose up -d

# Verify everything is running
docker-compose ps
```

### Option 2: Run from Downloaded Files
```bash
# Extract the project files to a folder
# Navigate to the project directory
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
NAME                          IMAGE         STATUS
privatbank_postgres_primary   postgres:15   Up (healthy)
privatbank_postgres_standby   postgres:15   Up (healthy)
privatbank_scheduler          postgres:15   Up
```

### 2. Verify Database Records
```bash
# Check primary database records
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"

# Check standby database records
docker-compose exec postgres-standby psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"
```
**Expected:** Both should show 100,000+ records

### 3. Check Replication Status
```bash
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"
```
**Expected:** Shows active WAL senders and replication slots

### 4. Verify Jobs are Running
```bash
docker-compose logs scheduler --tail=10
```
**Expected:** Shows insert and update jobs running every 5s and 3s

## 🔧 Management Commands

### Database Access
```bash
# Connect to primary database
docker-compose exec postgres-primary psql -U postgres -d privatbank_test

# Connect to standby database
docker-compose exec postgres-standby psql -U postgres -d privatbank_test
```

### Monitoring
```bash
# Check replication status
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"

# Check data counts
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"
docker-compose exec postgres-standby psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;"

# Check job status
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_job_status();"

# Check data quality
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_data_quality();"
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
```

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
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "\d t1"

# Test 2: Check partitions
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT schemaname, tablename FROM pg_tables WHERE tablename LIKE 't1_%' ORDER BY tablename;"

# Test 3: Verify materialized view
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM customer_totals LIMIT 5;"

# Test 4: Check replication sync
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM verify_table_replication();"

# Test 5: Monitor job execution
docker-compose logs scheduler --tail=20
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
docker-compose exec postgres-primary pg_isready -U postgres
docker-compose exec postgres-standby pg_isready -U postgres
```

#### Replication not working
```bash
# Check replication status
docker-compose exec postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"

# Manual subscription creation if needed
docker-compose exec postgres-standby psql -U postgres -d privatbank_test -c "SELECT * FROM pg_subscription;"
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
├── docker-compose.yml              # Main orchestration
├── scheduler.sh                    # Job scheduler script
├── init_primary.sql               # Primary database initialization
├── init_standby.sql               # Standby database initialization
├── schema/                        # Shared database schema
├── functions/                     # Core PostgreSQL functions
├── monitoring/                    # Monitoring functions
├── scripts/                       # Setup and utility scripts
├── README.md                      # Project documentation
└── TASK_DESCRIPTION.md           # Task requirements
```

---

**Built with ❤️ using PostgreSQL, Docker, and Logical Replication**
