# PrivatBank Test Task

> **PostgreSQL Database Implementation** with Automated Job Scheduling and Logical Replication

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- 4GB RAM minimum
- 2GB disk space

### Installation
```bash
# Clone the repository
git clone https://github.com/olegivanoviam/privatbank-test-task.git
cd privatbank-test-task

# Start the system
docker-compose up -d

# Verify everything is running
docker-compose ps
```

## 📊 System Overview

### What's Included
- **📋 Partitioned Table T1** - 100k+ test records with monthly partitions
- **⏰ Automated Jobs** - Insert every 5s, update every 3s
- **📈 Materialized View** - Customer totals with auto-refresh
- **🔄 Logical Replication** - Primary-standby setup
- **📊 Monitoring Functions** - System health and data quality checks

### Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PRIMARY       │    │   STANDBY       │    │   SCHEDULER     │
│   Port: 5432    │◄───┤   Port: 5433    │    │   Job Runner    │
│   Main DB       │    │   Replicated    │    │   Auto Tasks    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Management Commands

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
```

## 📋 Task Requirements

✅ **Partitioned table T1** - Monthly partitions by date  
✅ **100k+ test data** - Generated over 3-4 months  
✅ **Unique operation_guid** - UUID constraint  
✅ **Scheduled insert job** - Every 5 seconds, status=0  
✅ **Scheduled update job** - Every 3 seconds, even/odd based on seconds  
✅ **Materialized view** - Customer totals with automatic refresh  
✅ **Logical replication** - Table T1 replicated to standby instance  

## 🔧 Technical Details

### Database Schema
- **Table T1**: Partitioned by date with JSONB message field
- **Indexes**: Optimized for performance with GIN indexes on JSONB
- **Constraints**: Unique operation_guid per date
- **Partitions**: 24 monthly partitions (2024-2025)

### Replication
- **Type**: Logical replication (table-specific)
- **Primary**: Publishes changes to `privatbank_publication`
- **Standby**: Subscribes to publication for real-time sync
- **Monitoring**: Built-in replication status functions

### Job Scheduling
- **Insert Job**: Adds new records every 5 seconds
- **Update Job**: Updates status every 3 seconds (even/odd pattern)
- **Scheduler**: Docker container with continuous loop execution

## 🚨 Troubleshooting

### Common Issues
```bash
# Services won't start
docker-compose logs
docker-compose down && docker-compose up -d

# Database connection issues
docker-compose exec postgres-primary pg_isready -U postgres

# Check resource usage
docker stats
```

### Reset System
```bash
# Complete reset (removes all data)
docker-compose down -v
docker-compose up -d
```

## 📁 Project Structure

```
privatbank-test-task/
├── docker-compose.yml              # Main orchestration
├── scheduler.sh                    # Job scheduler script
├── init_primary.sql               # Primary database initialization
├── init_standby.sql               # Standby database initialization
├── schema/                        # Shared database schema
│   ├── create_table_t1.sql        # Partitioned table definition
│   ├── create_materialized_view.sql # Customer totals view
│   └── configure_table_replication.sql # Replication setup
├── functions/                     # Core PostgreSQL functions
│   ├── generate_test_data.sql     # Data generation function
│   ├── job_insert_transaction.sql # Insert job function
│   ├── job_update_status.sql      # Update job function
│   └── refresh_materialized_view.sql # MV refresh function
├── monitoring/                    # Monitoring functions
│   ├── check_data_quality.sql     # Data quality checks
│   ├── check_job_status.sql       # Job status monitoring
│   ├── check_replication_status.sql # Replication health
│   ├── check_standby_status.sql   # Standby monitoring
│   ├── get_replication_lag.sql    # Lag measurement
│   ├── test_replication.sql       # Replication testing
│   └── verify_table_replication.sql # Table replication check
├── scripts/                       # Setup and utility scripts
│   ├── primary_setup_database.sql # Primary data setup
│   ├── primary_setup_replication.sql # Primary replication setup
│   ├── standby_setup_replication.sql # Standby subscription
│   ├── verify_replication_status.sql # Replication verification
│   └── primary_health_check.sh    # Primary health check
├── README.md                      # This file
└── TASK_DESCRIPTION.md           # Task requirements
```

---

**Built with ❤️ using PostgreSQL, Docker, and Logical Replication**