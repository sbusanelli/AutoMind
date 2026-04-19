#!/bin/bash

# AutoMind Docker Build and Push Script
# This script builds and pushes Docker images to ECR

set -e

# Configuration
REGION="us-west-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
BACKEND_IMAGE="automind-backend"
FRONTEND_IMAGE="automind-frontend"
VERSION=${1:-latest}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install it first."
    fi
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed. Please install it first."
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running. Please start Docker."
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials are not configured. Please run 'aws configure'."
    fi
    
    log "Prerequisites check passed"
}

# Create ECR repositories
create_ecr_repositories() {
    log "Creating ECR repositories..."
    
    # Create backend repository
    aws ecr create-repository \
        --repository-name ${BACKEND_IMAGE} \
        --region ${REGION} \
        --image-scanning-configuration scanOnPush=true \
        --image-tag-mutability MUTABLE \
        --no-cli-pager 2>/dev/null || log "Backend repository already exists"
    
    # Create frontend repository
    aws ecr create-repository \
        --repository-name ${FRONTEND_IMAGE} \
        --region ${REGION} \
        --image-scanning-configuration scanOnPush=true \
        --image-tag-mutability MUTABLE \
        --no-cli-pager 2>/dev/null || log "Frontend repository already exists"
    
    log "ECR repositories created/verified"
}

# Login to ECR
login_to_ecr() {
    log "Logging in to ECR..."
    
    aws ecr get-login-password --region ${REGION} | \
        docker login --username AWS --password-stdin ${ECR_REGISTRY}
    
    if [ $? -eq 0 ]; then
        log "Successfully logged in to ECR"
    else
        error "Failed to login to ECR"
    fi
}

# Build backend image
build_backend() {
    log "Building backend Docker image..."
    
    cd backend
    
    # Create Dockerfile if it doesn't exist
    if [ ! -f "Dockerfile" ]; then
        log "Creating backend Dockerfile..."
        cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S automind -u 1001

# Change ownership of the app directory
RUN chown -R automind:nodejs /app
USER automind

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

EXPOSE 5000

CMD ["npm", "start"]
EOF
    fi
    
    # Build the image
    docker build -t ${BACKEND_IMAGE}:${VERSION} .
    
    if [ $? -eq 0 ]; then
        log "Backend image built successfully"
    else
        error "Failed to build backend image"
    fi
    
    cd ..
}

# Build frontend image
build_frontend() {
    log "Building frontend Docker image..."
    
    cd frontend
    
    # Create Dockerfile if it doesn't exist
    if [ ! -f "Dockerfile" ]; then
        log "Creating frontend Dockerfile..."
        cat > Dockerfile << 'EOF'
# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built app from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create non-root user
RUN addgroup -g 1001 -S nginx
RUN adduser -S automind -u 1001

# Change ownership
RUN chown -R automind:nginx /usr/share/nginx/html
RUN chown -R automind:nginx /var/cache/nginx
RUN chown -R automind:nginx /var/log/nginx
RUN chown -R automind:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid
RUN chown -R automind:nginx /var/run/nginx.pid

USER automind

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
EOF
    fi
    
    # Create nginx.conf if it doesn't exist
    if [ ! -f "nginx.conf" ]; then
        log "Creating nginx configuration..."
        cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       3000;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files $uri $uri/ /index.html;
        }

        location /api {
            proxy_pass http://backend:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF
    fi
    
    # Build the image
    docker build -t ${FRONTEND_IMAGE}:${VERSION} .
    
    if [ $? -eq 0 ]; then
        log "Frontend image built successfully"
    else
        error "Failed to build frontend image"
    fi
    
    cd ..
}

# Tag images for ECR
tag_images() {
    log "Tagging images for ECR..."
    
    # Tag backend image
    docker tag ${BACKEND_IMAGE}:${VERSION} ${ECR_REGISTRY}/${BACKEND_IMAGE}:${VERSION}
    
    # Tag frontend image
    docker tag ${FRONTEND_IMAGE}:${VERSION} ${ECR_REGISTRY}/${FRONTEND_IMAGE}:${VERSION}
    
    log "Images tagged successfully"
}

# Push images to ECR
push_images() {
    log "Pushing images to ECR..."
    
    # Push backend image
    docker push ${ECR_REGISTRY}/${BACKEND_IMAGE}:${VERSION}
    
    if [ $? -eq 0 ]; then
        log "Backend image pushed successfully"
    else
        error "Failed to push backend image"
    fi
    
    # Push frontend image
    docker push ${ECR_REGISTRY}/${FRONTEND_IMAGE}:${VERSION}
    
    if [ $? -eq 0 ]; then
        log "Frontend image pushed successfully"
    else
        error "Failed to push frontend image"
    fi
}

# Clean up local images
cleanup_local_images() {
    log "Cleaning up local images..."
    
    # Remove local tags
    docker rmi ${BACKEND_IMAGE}:${VERSION} 2>/dev/null || true
    docker rmi ${FRONTEND_IMAGE}:${VERSION} 2>/dev/null || true
    docker rmi ${ECR_REGISTRY}/${BACKEND_IMAGE}:${VERSION} 2>/dev/null || true
    docker rmi ${ECR_REGISTRY}/${FRONTEND_IMAGE}:${VERSION} 2>/dev/null || true
    
    log "Local images cleaned up"
}

# Display image information
show_image_info() {
    log "Image information:"
    echo "Backend: ${ECR_REGISTRY}/${BACKEND_IMAGE}:${VERSION}"
    echo "Frontend: ${ECR_REGISTRY}/${FRONTEND_IMAGE}:${VERSION}"
    echo ""
    echo "To use these images in Kubernetes, update the image references in:"
    echo "- infrastructure/kubernetes/backend.yaml"
    echo "- infrastructure/kubernetes/frontend.yaml"
}

# Main build function
main() {
    log "Starting AutoMind Docker build and push for version: ${VERSION}"
    
    # Run build steps
    check_prerequisites
    create_ecr_repositories
    login_to_ecr
    build_backend
    build_frontend
    tag_images
    push_images
    cleanup_local_images
    show_image_info
    
    log "Docker build and push completed successfully!"
}

# Help function
show_help() {
    echo "AutoMind Docker Build and Push Script"
    echo ""
    echo "Usage: $0 [VERSION]"
    echo ""
    echo "Arguments:"
    echo "  VERSION    Image version tag [default: latest]"
    echo ""
    echo "Examples:"
    echo "  $0 latest"
    echo "  $0 v1.0.0"
    echo "  $0 $(git rev-parse --short HEAD)"
    echo ""
    echo "Prerequisites:"
    echo "  - Docker installed and running"
    echo "  - AWS CLI configured"
    echo "  - Appropriate AWS permissions for ECR"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
