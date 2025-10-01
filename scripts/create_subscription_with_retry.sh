#!/bin/bash
set -e

# PostgreSQL Logical Replication Subscription Creation with Retry Logic
# Implements exponential backoff with jitter for production reliability

# Configuration
MAX_RETRIES=15
BASE_DELAY=1
MAX_DELAY=30
SUBSCRIPTION_NAME="privatbank_subscription"
PRIMARY_HOST="postgres-primary"
PRIMARY_PORT="5432"
PRIMARY_USER="replicator"
PRIMARY_PASSWORD="replicator_password"
PRIMARY_DB="privatbank_test"
PUBLICATION_NAME="privatbank_publication"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if subscription already exists
check_subscription_exists() {
    local count=$(psql -U postgres -d privatbank_test -t -c "SELECT COUNT(*) FROM pg_subscription WHERE subname = '$SUBSCRIPTION_NAME';" 2>/dev/null | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        return 0  # Subscription exists
    else
        return 1  # Subscription doesn't exist
    fi
}

# Function to test primary connectivity
test_primary_connectivity() {
    if pg_isready -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_USER" -d "$PRIMARY_DB" >/dev/null 2>&1; then
        return 0  # Primary is reachable
    else
        return 1  # Primary is not reachable
    fi
}

# Function to create subscription
create_subscription() {
    local sql="CREATE SUBSCRIPTION $SUBSCRIPTION_NAME
               CONNECTION 'host=$PRIMARY_HOST port=$PRIMARY_PORT user=$PRIMARY_USER password=$PRIMARY_PASSWORD dbname=$PRIMARY_DB'
               PUBLICATION $PUBLICATION_NAME;"
    
    if psql -U postgres -d privatbank_test -c "$sql" >/dev/null 2>&1; then
        return 0  # Success
    else
        return 1  # Failed
    fi
}

# Main retry logic with exponential backoff and jitter
main() {
    log_info "Starting subscription creation with retry logic..."
    log_info "Configuration: MAX_RETRIES=$MAX_RETRIES, BASE_DELAY=${BASE_DELAY}s, MAX_DELAY=${MAX_DELAY}s"
    
    # Check if subscription already exists
    if check_subscription_exists; then
        log_success "Subscription '$SUBSCRIPTION_NAME' already exists - no action needed"
        exit 0
    fi
    
    log_info "Subscription '$SUBSCRIPTION_NAME' does not exist - will create with retry logic"
    
    local attempt=1
    local success=false
    local last_error=""
    
    while [ $attempt -le $MAX_RETRIES ] && [ "$success" = false ]; do
        log_info "Attempt $attempt of $MAX_RETRIES..."
        
        # Test primary connectivity first
        if ! test_primary_connectivity; then
            last_error="Primary database not reachable"
            log_warning "Primary connectivity test failed: $last_error"
        else
            log_info "Primary connectivity test passed"
            
            # Try to create subscription
            if create_subscription; then
                log_success "Subscription '$SUBSCRIPTION_NAME' created successfully on attempt $attempt"
                success=true
                break
            else
                last_error="CREATE SUBSCRIPTION command failed"
                log_warning "Subscription creation failed: $last_error"
            fi
        fi
        
        # If not the last attempt, calculate delay with exponential backoff and jitter
        if [ $attempt -lt $MAX_RETRIES ]; then
            # Exponential backoff: delay = base_delay * (2 ^ (attempt - 1))
            local delay=$((BASE_DELAY * (2 ** (attempt - 1))))
            
            # Add jitter: random value between 0 and 4 seconds
            local jitter=$((RANDOM % 5))
            delay=$((delay + jitter))
            
            # Cap at maximum delay
            if [ $delay -gt $MAX_DELAY ]; then
                delay=$MAX_DELAY
            fi
            
            log_info "Retrying in ${delay}s (base: $((BASE_DELAY * (2 ** (attempt - 1))))s + jitter: ${jitter}s)..."
            sleep $delay
        fi
        
        attempt=$((attempt + 1))
    done
    
    # Final result
    if [ "$success" = true ]; then
        log_success "Subscription creation completed successfully!"
        
        # Verify subscription is active
        if check_subscription_exists; then
            log_success "Subscription verification passed - replication is ready"
        else
            log_error "Subscription verification failed - subscription not found after creation"
            exit 1
        fi
    else
        log_error "All $MAX_RETRIES attempts failed"
        log_error "Last error: $last_error"
        log_error "Please check primary database status and network connectivity"
        exit 1
    fi
}

# Run main function
main "$@"
