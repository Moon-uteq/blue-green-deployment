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
else
    OLD_ENV="blue"
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

# Create completely new nginx config pointing to target environment
if [ "$TARGET_ENV" = "blue" ]; then
    # Configuration for BLUE active
    cat > $TEMP_CONFIG << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream blue_green_backend {
        server app-blue:80;
        server app-green:80 backup;
    }

    server {
        listen 80;
        server_name localhost;

        location /lb-health {
            access_log off;
            return 200 "Load balancer is healthy\n";
            add_header Content-Type text/plain;
        }

        location / {
            proxy_pass http://blue_green_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_connect_timeout 1s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        location /status {
            access_log off;
            return 200 "Active environment info\n";
            add_header Content-Type text/plain;
            add_header X-Active-Environment "blue";
        }
    }
}
EOF
else
    # Configuration for GREEN active
    cat > $TEMP_CONFIG << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream blue_green_backend {
        server app-blue:80 backup;
        server app-green:80;
    }

    server {
        listen 80;
        server_name localhost;

        location /lb-health {
            access_log off;
            return 200 "Load balancer is healthy\n";
            add_header Content-Type text/plain;
        }

        location / {
            proxy_pass http://blue_green_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_connect_timeout 1s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        location /status {
            access_log off;
            return 200 "Active environment info\n";
            add_header Content-Type text/plain;
            add_header X-Active-Environment "green";
        }
    }
}
EOF
fi

# Update local nginx configuration file
log "Updating local nginx configuration..."
cp $TEMP_CONFIG nginx/nginx.conf

# Recreate only nginx container
log "Recreating nginx load balancer with new configuration..."
docker-compose stop nginx-lb
docker-compose rm -f nginx-lb  
docker-compose up -d nginx-lb

# Wait for container to be ready
sleep 10

# Clean up temporary file
rm $TEMP_CONFIG

# Verify the switch was successful
log "Verifying traffic switch..."
ACTIVE_ENV_HEADER=$(curl -s -I http://localhost:8080/status | grep X-Active-Environment || echo "")

if [[ "$ACTIVE_ENV_HEADER" == *"$TARGET_ENV"* ]]; then
    success "Traffic successfully switched to $TARGET_ENV environment!"
else
    warning "Could not verify active environment header. Manual verification recommended."
fi

log "Current deployment status:"
echo "Active Environment: $TARGET_ENV"
echo "Inactive Environment: $OLD_ENV"
echo ""
log "You can now safely update the $OLD_ENV environment for the next deployment."

success "Traffic switch completed successfully!"