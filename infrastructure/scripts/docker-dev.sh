#!/bin/bash

# AutoMind Docker Development Script
# This script manages the local Docker development environment

set -e

# Configuration
COMPOSE_FILE="infrastructure/docker/docker-compose.dev.yml"
ENV_FILE="infrastructure/docker/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install it first."
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install it first."
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running. Please start Docker."
    fi
    
    log "Prerequisites check passed"
}

# Setup environment
setup_environment() {
    log "Setting up environment..."
    
    # Create .env file if it doesn't exist
    if [ ! -f "$ENV_FILE" ]; then
        log "Creating .env file from template..."
        cp infrastructure/docker/.env.example "$ENV_FILE"
        warn "Please update $ENV_FILE with your configuration"
    fi
    
    # Create necessary directories
    mkdir -p infrastructure/docker/monitoring/grafana/dashboards
    mkdir -p infrastructure/docker/monitoring/prometheus
    
    log "Environment setup completed"
}

# Start development environment
start_dev() {
    log "Starting AutoMind development environment..."
    
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    if [ $? -eq 0 ]; then
        log "Development environment started successfully"
        show_services
    else
        error "Failed to start development environment"
    fi
}

# Stop development environment
stop_dev() {
    log "Stopping AutoMind development environment..."
    
    docker-compose -f "$COMPOSE_FILE" down
    
    if [ $? -eq 0 ]; then
        log "Development environment stopped successfully"
    else
        error "Failed to stop development environment"
    fi
}

# Reset development environment
reset_dev() {
    log "Resetting AutoMind development environment..."
    
    docker-compose -f "$COMPOSE_FILE" down -v --remove-orphans
    
    # Remove volumes
    docker volume prune -f
    
    if [ $? -eq 0 ]; then
        log "Development environment reset successfully"
    else
        error "Failed to reset development environment"
    fi
}

# Show service status
show_services() {
    log "AutoMind Development Services:"
    echo ""
    echo "Frontend:      http://localhost:3000"
    echo "Backend API:   http://localhost:5000"
    echo "Database:      postgresql://localhost:5432/automind"
    echo "Redis:         redis://localhost:6379"
    echo "Adminer:       http://localhost:8080 (Database Admin)"
    echo "Redis Commander: http://localhost:8081 (Redis Admin)"
    echo ""
    echo "Service Status:"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Show logs
show_logs() {
    local service=${1:-}
    
    if [ -n "$service" ]; then
        log "Showing logs for $service..."
        docker-compose -f "$COMPOSE_FILE" logs -f "$service"
    else
        log "Showing logs for all services..."
        docker-compose -f "$COMPOSE_FILE" logs -f
    fi
}

# Execute command in service
exec_service() {
    local service=$1
    shift
    
    if [ -z "$service" ]; then
        error "Service name is required. Usage: $0 exec <service> [command]"
    fi
    
    log "Executing command in $service..."
    docker-compose -f "$COMPOSE_FILE" exec "$service" "$@"
}

# Build images
build_images() {
    log "Building Docker images..."
    
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    
    if [ $? -eq 0 ]; then
        log "Docker images built successfully"
    else
        error "Failed to build Docker images"
    fi
}

# Pull latest images
pull_images() {
    log "Pulling latest Docker images..."
    
    docker-compose -f "$COMPOSE_FILE" pull
    
    if [ $? -eq 0 ]; then
        log "Docker images pulled successfully"
    else
        error "Failed to pull Docker images"
    fi
}

# Update dependencies
update_dependencies() {
    log "Updating dependencies..."
    
    # Update backend dependencies
    log "Updating backend dependencies..."
    docker-compose -f "$COMPOSE_FILE" exec backend npm update
    
    # Update frontend dependencies
    log "Updating frontend dependencies..."
    docker-compose -f "$COMPOSE_FILE" exec frontend npm update
    
    log "Dependencies updated successfully"
}

# Run tests
run_tests() {
    log "Running tests..."
    
    # Run backend tests
    log "Running backend tests..."
    docker-compose -f "$COMPOSE_FILE" exec backend npm test
    
    # Run frontend tests
    log "Running frontend tests..."
    docker-compose -f "$COMPOSE_FILE" exec frontend npm test
    
    log "Tests completed"
}

# Database operations
db_operations() {
    local operation=$1
    
    case "$operation" in
        "migrate")
            log "Running database migrations..."
            docker-compose -f "$COMPOSE_FILE" exec backend npm run db:migrate
            ;;
        "seed")
            log "Seeding database..."
            docker-compose -f "$COMPOSE_FILE" exec backend npm run db:seed
            ;;
        "reset")
            log "Resetting database..."
            docker-compose -f "$COMPOSE_FILE" exec postgres psql -U postgres -c "DROP DATABASE IF EXISTS automind; CREATE DATABASE automind;"
            ;;
        "backup")
            log "Creating database backup..."
            docker-compose -f "$COMPOSE_FILE" exec postgres pg_dump -U postgres automind > "automind-backup-$(date +%Y%m%d-%H%M%S).sql"
            ;;
        *)
            error "Unknown database operation: $operation"
            ;;
    esac
}

# Show help
show_help() {
    echo "AutoMind Docker Development Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start           Start development environment"
    echo "  stop            Stop development environment"
    echo "  restart         Restart development environment"
    echo "  reset           Reset development environment (remove all data)"
    echo "  status          Show service status"
    echo "  logs [service]  Show logs (all services or specific service)"
    echo "  exec <service>  Execute command in service"
    echo "  build           Build Docker images"
    echo "  pull            Pull latest Docker images"
    echo "  update          Update dependencies"
    echo "  test            Run tests"
    echo "  db <operation>  Database operations (migrate|seed|reset|backup)"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all services"
    echo "  $0 logs backend            # Show backend logs"
    echo "  $0 exec backend bash       # Execute bash in backend"
    echo "  $0 db migrate              # Run database migrations"
    echo ""
    echo "Services:"
    echo "  frontend        React frontend application"
    echo "  backend         Node.js backend API"
    echo "  postgres        PostgreSQL database"
    echo "  redis           Redis cache"
    echo "  adminer         Database admin interface"
    echo "  redis-commander Redis admin interface"
}

# Main function
main() {
    local command=${1:-help}
    
    case "$command" in
        "start")
            check_prerequisites
            setup_environment
            start_dev
            ;;
        "stop")
            stop_dev
            ;;
        "restart")
            stop_dev
            sleep 2
            start_dev
            ;;
        "reset")
            reset_dev
            ;;
        "status")
            show_services
            ;;
        "logs")
            show_logs "${2:-}"
            ;;
        "exec")
            exec_service "$2" "${@:3}"
            ;;
        "build")
            check_prerequisites
            build_images
            ;;
        "pull")
            check_prerequisites
            pull_images
            ;;
        "update")
            check_prerequisites
            update_dependencies
            ;;
        "test")
            check_prerequisites
            run_tests
            ;;
        "db")
            check_prerequisites
            db_operations "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            error "Unknown command: $command. Use '$0 help' for usage information."
            ;;
    esac
}

# Execute main function
main "$@"
