#!/bin/bash

# Blue-Green Deployment Script
# Usage: ./deploy.sh [version] [environment]
# Example: ./deploy.sh v1.2.3 green

set -e  # Exit on any error

# Configuration
PROJECT_NAME="blue-green-app"
COMPOSE_FILE="docker-compose.yml"
NGINX_CONTAINER="nginx-lb"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
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

# Check if required parameters are provided
if [ $# -ne 2 ]; then
    error "Usage: $0 <version> <environment>"
    error "Example: $0 v1.2.3 green"
    exit 1
fi

VERSION=$1
ENVIRONMENT=$2

# Validate environment
if [[ "$ENVIRONMENT" != "blue" && "$ENVIRONMENT" != "green" ]]; then
    error "Environment must be 'blue' or 'green'"
    exit 1
fi

log "Starting deployment of version $VERSION to $ENVIRONMENT environment"

# Build new image with version tag
log "Building Docker image for $ENVIRONMENT environment..."
docker build -t $PROJECT_NAME:$VERSION .

# Tag image for the specific environment
docker tag $PROJECT_NAME:$VERSION $PROJECT_NAME:$ENVIRONMENT

# Stop and remove existing container for this environment
log "Stopping existing $ENVIRONMENT container..."
docker-compose stop app-$ENVIRONMENT || true
docker-compose rm -f app-$ENVIRONMENT || true

# Start new container for this environment
log "Starting new $ENVIRONMENT container with version $VERSION..."
docker-compose up -d app-$ENVIRONMENT

# Wait for container to be ready
log "Waiting for $ENVIRONMENT environment to be ready..."
sleep 30

# Health check
log "Performing health check on $ENVIRONMENT environment..."
if ! ./scripts/health-check.sh $ENVIRONMENT; then
    error "Health check failed for $ENVIRONMENT environment"
    error "Rolling back..."
    docker-compose stop app-$ENVIRONMENT
    exit 1
fi

success "Deployment of version $VERSION to $ENVIRONMENT environment completed successfully!"

log "Current status:"
docker-compose ps

log "To switch traffic to $ENVIRONMENT, run: ./scripts/switch.sh $ENVIRONMENT"