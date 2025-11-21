#!/bin/bash

# Blue-Green Traffic Switch Script
# Usage: ./switch.sh [environment]
# Example: ./switch.sh green

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[SWITCH]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if environment parameter is provided
if [ $# -ne 1 ]; then
    error "Usage: $0 <environment>"
    error "Example: $0 green"
    exit 1
fi

TARGET_ENV=$1

# Validate environment
if [[ "$TARGET_ENV" != "blue" && "$TARGET_ENV" != "green" ]]; then
    error "Environment must be 'blue' or 'green'"
    exit 1
fi

# Determine the other environment
if [ "$TARGET_ENV" = "blue" ]; then
    OLD_ENV="green"
    NEW_PORT=3001
    OLD_PORT=3002
else
    OLD_ENV="blue"
    NEW_PORT=3002
    OLD_PORT=3001
fi

log "Switching traffic from $OLD_ENV to $TARGET_ENV environment"

# Perform final health check on target environment
log "Performing final health check on $TARGET_ENV before switch..."
if ! ./scripts/health-check.sh $TARGET_ENV; then
    error "Health check failed for $TARGET_ENV environment. Aborting switch."
    exit 1
fi

# Create new nginx configuration
log "Updating nginx configuration to point to $TARGET_ENV..."

# Create temporary nginx config
TEMP_CONFIG="/tmp/nginx_temp.conf"
cp nginx/nginx.conf $TEMP_CONFIG

# Update upstream configuration to point to new environment
if [ "$TARGET_ENV" = "blue" ]; then
    sed -i 's/server app-blue:80 weight=0 backup;/server app-blue:80 weight=100;/' $TEMP_CONFIG
    sed -i 's/server app-green:80 weight=100;/server app-green:80 weight=0 backup;/' $TEMP_CONFIG
    sed -i 's/add_header X-Active-Environment "green";/add_header X-Active-Environment "blue";/' $TEMP_CONFIG
else
    sed -i 's/server app-blue:80 weight=100;/server app-blue:80 weight=0 backup;/' $TEMP_CONFIG
    sed -i 's/server app-green:80 weight=0 backup;/server app-green:80 weight=100;/' $TEMP_CONFIG
    sed -i 's/add_header X-Active-Environment "blue";/add_header X-Active-Environment "green";/' $TEMP_CONFIG
fi

# Copy new configuration to nginx container
log "Applying new nginx configuration..."
docker cp $TEMP_CONFIG $(docker-compose ps -q nginx-lb):/etc/nginx/nginx.conf

# Reload nginx configuration
log "Reloading nginx configuration..."
docker-compose exec nginx-lb nginx -s reload

# Clean up temporary file
rm $TEMP_CONFIG

# Wait a moment for the switch to take effect
sleep 2

# Verify the switch was successful
log "Verifying traffic switch..."
ACTIVE_ENV_HEADER=$(curl -s -I http://localhost:8080/status | grep X-Active-Environment || echo "")

if [[ "$ACTIVE_ENV_HEADER" == *"$TARGET_ENV"* ]]; then
    success "Traffic successfully switched to $TARGET_ENV environment!"
else
    warning "Could not verify active environment header. Manual verification recommended."
fi

# Update the main nginx config file for persistence
log "Updating persistent nginx configuration..."
cp nginx/nginx.conf nginx/nginx.conf.bak

if [ "$TARGET_ENV" = "blue" ]; then
    sed -i 's/server app-blue:80 weight=0 backup;/server app-blue:80 weight=100;/' nginx/nginx.conf
    sed -i 's/server app-green:80 weight=100;/server app-green:80 weight=0 backup;/' nginx/nginx.conf
    sed -i 's/add_header X-Active-Environment "green";/add_header X-Active-Environment "blue";/' nginx/nginx.conf
else
    sed -i 's/server app-blue:80 weight=100;/server app-blue:80 weight=0 backup;/' nginx/nginx.conf
    sed -i 's/server app-green:80 weight=0 backup;/server app-green:80 weight=100;/' nginx/nginx.conf
    sed -i 's/add_header X-Active-Environment "blue";/add_header X-Active-Environment "green";/' nginx/nginx.conf
fi

log "Current deployment status:"
echo "Active Environment: $TARGET_ENV"
echo "Inactive Environment: $OLD_ENV"
echo ""
log "You can now safely update the $OLD_ENV environment for the next deployment."

success "Traffic switch completed successfully!"