# AutoMind Docker Development

This directory contains Docker configurations for local development and deployment of AutoMind.

## Overview

AutoMind uses Docker for containerized development and deployment. The setup includes:

- **Development Environment**: Hot-reload containers with debugging capabilities
- **Production Environment**: Optimized containers for deployment
- **Database Services**: PostgreSQL and Redis containers
- **Monitoring**: Prometheus and Grafana for observability
- **Development Tools**: Adminer and Redis Commander for database management

## Quick Start

### Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- Node.js 18+ (for local development outside Docker)
- Git

### 1. Environment Setup

```bash
# Copy environment template
cp infrastructure/docker/.env.example infrastructure/docker/.env

# Edit the .env file with your configuration
nano infrastructure/docker/.env
```

### 2. Start Development Environment

```bash
# Start all services
./infrastructure/scripts/docker-dev.sh start

# Check service status
./infrastructure/scripts/docker-dev.sh status
```

### 3. Access Services

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **Database Admin**: http://localhost:8080 (Adminer)
- **Redis Admin**: http://localhost:8081 (Redis Commander)
- **API Documentation**: http://localhost:5000/docs

## Directory Structure

```
infrastructure/docker/
|-- docker-compose.yml          # Production deployment
|-- docker-compose.dev.yml      # Development environment
|-- Dockerfile.backend          # Production backend image
|-- Dockerfile.frontend         # Production frontend image
|-- Dockerfile.dev.backend      # Development backend image
|-- Dockerfile.dev.frontend     # Development frontend image
|-- nginx.conf                  # Nginx configuration
|-- default.conf                 # Frontend Nginx config
|-- .env.example                # Environment template
|-- init.sql                    # Database initialization
|-- monitoring/                 # Monitoring configurations
|   |-- prometheus.yml
|   `-- grafana/
|       `-- dashboards/
`-- README.md                   # This file
```

## Docker Compose Files

### Production (`docker-compose.yml`)

Optimized for production deployment with:
- Multi-stage builds for smaller images
- Non-root user execution
- Health checks and monitoring
- Persistent volumes for data
- Network isolation

### Development (`docker-compose.dev.yml`)

Optimized for local development with:
- Hot-reload enabled
- Volume mounts for live code changes
- Debugging ports exposed
- Development tools included
- Development database seeding

## Docker Images

### Backend Images

#### Production (`Dockerfile.backend`)
- Multi-stage build
- Production dependencies only
- Security hardening
- Health checks
- Optimized for size

#### Development (`Dockerfile.dev.backend`)
- Development dependencies
- Debugging enabled
- Volume mounts support
- Hot-reload capabilities

### Frontend Images

#### Production (`Dockerfile.frontend`)
- Multi-stage build (build + nginx)
- Static asset optimization
- Gzip compression
- Security headers
- Non-root execution

#### Development (`Dockerfile.dev.frontend`)
- Development server
- Hot-reload enabled
- Volume mounts support
- Development dependencies

## Environment Variables

### Database Configuration
```bash
DB_PASSWORD=postgres123          # PostgreSQL password
DB_HOST=postgres                 # Database host
DB_PORT=5432                     # Database port
DB_NAME=automind                 # Database name
DB_USER=postgres                 # Database user
```

### Redis Configuration
```bash
REDIS_HOST=redis                 # Redis host
REDIS_PORT=6379                   # Redis port
REDIS_PASSWORD=                   # Redis password (optional)
```

### Application Configuration
```bash
NODE_ENV=development             # Environment
PORT=5000                        # Backend port
JWT_SECRET=your-secret-key       # JWT signing secret
FRONTEND_URL=http://localhost:3000  # Frontend URL
```

### AI Configuration
```bash
OPENAI_API_KEY=your-openai-key   # OpenAI API key
AI_MODEL_ENDPOINT=https://api.openai.com/v1/chat/completions
AI_MAX_TOKENS=2048                # Max tokens for AI responses
AI_TEMPERATURE=0.7               # AI response temperature
```

## Development Scripts

The `docker-dev.sh` script provides convenient commands for managing the development environment:

```bash
# Start all services
./infrastructure/scripts/docker-dev.sh start

# Stop all services
./infrastructure/scripts/docker-dev.sh stop

# Restart services
./infrastructure/scripts/docker-dev.sh restart

# Show service status
./infrastructure/scripts/docker-dev.sh status

# Show logs
./infrastructure/scripts/docker-dev.sh logs [service]

# Execute command in service
./infrastructure/scripts/docker-dev.sh exec <service> <command>

# Build images
./infrastructure/scripts/docker-dev.sh build

# Update dependencies
./infrastructure/scripts/docker-dev.sh update

# Run tests
./infrastructure/scripts/docker-dev.sh test

# Database operations
./infrastructure/scripts/docker-dev.sh db migrate
./infrastructure/scripts/docker-dev.sh db seed
./infrastructure/scripts/docker-dev.sh db reset
./infrastructure/scripts/docker-dev.sh db backup
```

## Development Workflow

### 1. Initial Setup

```bash
# Clone and setup
git clone https://github.com/sbusanelli/AutoMind.git
cd AutoMind

# Setup environment
cp infrastructure/docker/.env.example infrastructure/docker/.env

# Start development environment
./infrastructure/scripts/docker-dev.sh start
```

### 2. Daily Development

```bash
# Start services (if not running)
./infrastructure/scripts/docker-dev.sh start

# View logs
./infrastructure/scripts/docker-dev.sh logs

# Access backend container
./infrastructure/scripts/docker-dev.sh exec backend bash

# Access frontend container
./infrastructure/scripts/docker-dev.sh exec frontend bash
```

### 3. Testing

```bash
# Run all tests
./infrastructure/scripts/docker-dev.sh test

# Run backend tests only
./infrastructure/scripts/docker-dev.sh exec backend npm test

# Run frontend tests only
./infrastructure/scripts/docker-dev.sh exec frontend npm test
```

### 4. Database Management

```bash
# Run migrations
./infrastructure/scripts/docker-dev.sh db migrate

# Seed database
./infrastructure/scripts/docker-dev.sh db seed

# Reset database
./infrastructure/scripts/docker-dev.sh db reset

# Create backup
./infrastructure/scripts/docker-dev.sh db backup
```

## Production Deployment

### 1. Build Production Images

```bash
# Build and push to registry
./infrastructure/scripts/build-and-push.sh latest

# Or build locally
docker-compose -f infrastructure/docker/docker-compose.yml build
```

### 2. Deploy Production

```bash
# Deploy to production
docker-compose -f infrastructure/docker/docker-compose.yml up -d

# Check status
docker-compose -f infrastructure/docker/docker-compose.yml ps
```

## Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check what's using ports
   lsof -i :3000
   lsof -i :5000
   
   # Stop conflicting services
   ./infrastructure/scripts/docker-dev.sh stop
   ```

2. **Permission Issues**
   ```bash
   # Fix Docker permissions
   sudo chown -R $USER:$USER .
   
   # Reset Docker
   docker system prune -f
   ```

3. **Database Connection Issues**
   ```bash
   # Check database status
   ./infrastructure/scripts/docker-dev.sh exec postgres pg_isready -U postgres
   
   # View database logs
   ./infrastructure/scripts/docker-dev.sh logs postgres
   ```

4. **Build Issues**
   ```bash
   # Clean build
   ./infrastructure/scripts/docker-dev.sh reset
   ./infrastructure/scripts/docker-dev.sh build
   ```

### Debug Commands

```bash
# Check container status
docker-compose -f infrastructure/docker/docker-compose.dev.yml ps

# View container logs
docker-compose -f infrastructure/docker/docker-compose.dev.yml logs [service]

# Execute in container
docker-compose -f infrastructure/docker/docker-compose.dev.yml exec [service] bash

# Inspect container
docker inspect [container_name]

# View resource usage
docker stats
```

## Performance Optimization

### Development

- Use volume mounts for hot-reload
- Enable source maps for debugging
- Use development dependencies

### Production

- Use multi-stage builds
- Minimize image sizes
- Remove development dependencies
- Enable gzip compression
- Use CDN for static assets

## Security

### Container Security

- Non-root user execution
- Minimal base images
- Security scanning
- Regular updates

### Network Security

- Isolated networks
- No exposed ports in production
- TLS encryption
- Security headers

### Data Security

- Encrypted secrets
- Database encryption
- Backup encryption
- Access control

## Monitoring

### Health Checks

All containers include health checks:

```bash
# Check health status
docker-compose -f infrastructure/docker/docker-compose.yml ps
```

### Metrics

- Application metrics via Prometheus
- System metrics via cAdvisor
- Database metrics
- Custom business metrics

### Logging

- Structured JSON logging
- Centralized log aggregation
- Log rotation
- Error tracking

## Contributing

When contributing to AutoMind:

1. Test with Docker development environment
2. Update Docker images if needed
3. Update documentation
4. Test production deployment
5. Update environment variables if required

## Support

For Docker-related issues:

1. Check this documentation
2. Review troubleshooting section
3. Create GitHub issue with:
   - Docker version
   - Operating system
   - Error logs
   - Steps to reproduce

---

**Note**: This Docker setup is optimized for both development and production use. Adjust configurations based on your specific requirements and environment.
