#!/bin/bash
set -e

# Standby Database Entrypoint with Retry Logic
# Handles PostgreSQL startup and subscription creation with exponential backoff

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[STANDBY-INIT]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[STANDBY-INIT]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[STANDBY-INIT]${NC} $1"
}

log_info "Starting standby database initialization..."

# Start PostgreSQL in the background
log_info "Starting PostgreSQL server..."
exec docker-entrypoint.sh postgres -c wal_level=logical &
POSTGRES_PID=$!

# Wait for PostgreSQL to be ready
log_info "Waiting for PostgreSQL to be ready..."
until pg_isready -U postgres -d privatbank_test >/dev/null 2>&1; do
    log_info "PostgreSQL is not ready yet, waiting..."
    sleep 2
done

log_success "PostgreSQL is ready!"

# Run the SQL initialization scripts
log_info "Running SQL initialization scripts..."
psql -U postgres -d privatbank_test -f /docker-entrypoint-initdb.d/init_standby.sql

log_success "SQL initialization complete!"

# Run the subscription creation with retry logic
log_info "Starting subscription creation with retry logic..."
chmod +x /scripts/create_subscription_with_retry.sh

if /scripts/create_subscription_with_retry.sh; then
    log_success "Standby initialization completed successfully!"
    log_success "Replication is ready and active!"
else
    log_warning "Subscription creation failed, but PostgreSQL is running"
    log_warning "You may need to manually create the subscription"
fi

# Wait for PostgreSQL process
log_info "Standby database is ready. Waiting for PostgreSQL process..."
wait $POSTGRES_PID
