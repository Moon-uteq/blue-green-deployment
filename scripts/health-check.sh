#!/bin/bash

# Health Check Script for Blue-Green Deployment
# Usage: ./health-check.sh [environment]
# Example: ./health-check.sh green

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[HEALTH CHECK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if environment parameter is provided
if [ $# -ne 1 ]; then
    error "Usage: $0 <environment>"
    error "Example: $0 green"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
if [[ "$ENVIRONMENT" != "blue" && "$ENVIRONMENT" != "green" ]]; then
    error "Environment must be 'blue' or 'green'"
    exit 1
fi

# Determine port based on environment
if [ "$ENVIRONMENT" = "blue" ]; then
    PORT=3001
else
    PORT=3002
fi

log "Checking health of $ENVIRONMENT environment on port $PORT"

# Check if container is running
CONTAINER_NAME="blue-green-app-app-$ENVIRONMENT-1"
if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
    error "Container $CONTAINER_NAME is not running"
    exit 1
fi

log "Container is running, checking HTTP endpoint..."

# HTTP health check with retries
MAX_RETRIES=30
RETRY_INTERVAL=2
HEALTH_URL="http://localhost:$PORT/health"

for i in $(seq 1 $MAX_RETRIES); do
    log "Attempt $i/$MAX_RETRIES: Checking $HEALTH_URL"
    
    if curl -f -s --max-time 5 "$HEALTH_URL" > /dev/null 2>&1; then
        success "Health check passed for $ENVIRONMENT environment!"
        
        # Additional check: verify the main application endpoint
        if curl -f -s --max-time 5 "http://localhost:$PORT/" > /dev/null 2>&1; then
            success "Main application endpoint is also responding correctly!"
            exit 0
        else
            error "Health endpoint is responding but main application is not"
            exit 1
        fi
    fi
    
    if [ $i -lt $MAX_RETRIES ]; then
        log "Health check failed, retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
    fi
done

error "Health check failed after $MAX_RETRIES attempts for $ENVIRONMENT environment"
exit 1