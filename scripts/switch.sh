#!/bin/bash

# Auto Blue-Green Deployment and Switch Script
# Usage: ./switch.sh (no parameters needed - detects automatically)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[AUTO-DEPLOY]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log "🚀 Starting automatic Blue-Green deployment..."

# Detect current active environment
log "🔍 Detecting current active environment..."
ACTIVE_ENV=$(curl -s -I http://localhost:8080/status | grep X-Active-Environment | cut -d' ' -f2 | tr -d '\r')

if [ -z "$ACTIVE_ENV" ]; then
    # If no environment is detected, default to blue
    ACTIVE_ENV="blue"
    log "⚠️  No active environment detected, defaulting to blue"
fi

# Determine target environment (deploy to inactive)
if [ "$ACTIVE_ENV" = "blue" ]; then
    TARGET_ENV="green"
    log "🟦 Blue is currently ACTIVE → Deploying to GREEN"
else
    TARGET_ENV="blue"  
    log "🟢 Green is currently ACTIVE → Deploying to BLUE"
fi

# Deploy to target environment
log "📦 Building and deploying to $TARGET_ENV environment..."
docker-compose stop app-$TARGET_ENV || true
docker-compose rm -f app-$TARGET_ENV || true
docker-compose build --no-cache app-$TARGET_ENV
docker-compose up -d app-$TARGET_ENV

# Wait for deployment
log "⏳ Waiting for $TARGET_ENV environment to be ready..."
sleep 30

# Health check
log "❤️ Performing health check on $TARGET_ENV..."
if ! ./scripts/health-check.sh $TARGET_ENV; then
    error "Health check failed for $TARGET_ENV environment. Aborting."
    exit 1
fi

# Auto-switch traffic
log "🔄 Switching traffic from $ACTIVE_ENV to $TARGET_ENV..."

# Create new nginx config
TEMP_CONFIG="/tmp/nginx_temp.conf"

if [ "$TARGET_ENV" = "blue" ]; then
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

# Apply new nginx config
cp $TEMP_CONFIG nginx/nginx.conf
docker-compose stop nginx-lb
docker-compose rm -f nginx-lb  
docker-compose up -d nginx-lb
sleep 10

# Cleanup
rm $TEMP_CONFIG

success "🎉 Deployment complete! $TARGET_ENV is now ACTIVE on port 8080"
log "📊 Status: $ACTIVE_ENV (inactive) ← $TARGET_ENV (ACTIVE)"