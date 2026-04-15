#!/bin/bash

# GitDiagram Repository Visualization Script
# Generates architecture diagrams for AutoMind repository
# Uses https://gitdiagram.com/ API to create visual representations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/sbusanelli/AutoMind"
DIAGRAMS_DIR="diagrams"
GITDIAGRAM_API="https://gitdiagram.com/api"
OUTPUT_DIR="docs/diagrams"

# Functions
print_header() {
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed"
        exit 1
    fi
    print_success "curl found"
    
    if ! command -v git &> /dev/null; then
        print_error "git is not installed"
        exit 1
    fi
    print_success "git found"
}

# Create output directory
setup_output_dir() {
    print_header "Setting Up Output Directory"
    
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        print_success "Created $OUTPUT_DIR"
    else
        print_info "Directory $OUTPUT_DIR already exists"
    fi
}

# Generate repository tree diagram
generate_tree_diagram() {
    print_header "Generating Repository Structure Tree"
    
    local tree_file="$OUTPUT_DIR/repository-tree.txt"
    
    # Generate tree structure (using find as fallback if tree not installed)
    if command -v tree &> /dev/null; then
        tree -L 3 -I 'node_modules|dist|.git' > "$tree_file" 2>/dev/null || true
    else
        # Fallback: use find to generate tree-like structure
        find . -maxdepth 3 -type f \( \
            -not -path '*/node_modules/*' \
            -not -path '*/.git/*' \
            -not -path '*/dist/*' \
            -not -path '*/.next/*' \
            \) | sort | sed 's|[^/]*/| |g' > "$tree_file"
    fi
    
    print_success "Repository tree saved to $tree_file"
}

# Generate architecture diagram documentation
generate_architecture_diagrams() {
    print_header "Generating Architecture Diagrams"
    
    local arch_file="$OUTPUT_DIR/architecture-diagrams.md"
    
    cat > "$arch_file" << 'EOF'
# AutoMind Architecture Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AutoMind System                          │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────┐
│   Client Layer           │
├──────────────────────────┤
│  • Web Browser (React)   │
│  • Mobile Apps           │
│  • CLI Tools             │
└──────────┬───────────────┘
           │
           ▼ HTTPS / WebSocket
┌──────────────────────────────────────────┐
│    API Gateway & Reverse Proxy           │
├──────────────────────────────────────────┤
│  Nginx                                   │
│  • TLS Termination                       │
│  • Rate Limiting                         │
│  • Load Balancing                        │
└──────────┬───────────────────────────────┘
           │
           ▼ HTTP / gRPC
┌────────────────────────────────────────────────────────┐
│            Application Services Layer                  │
├────────────────────────────────────────────────────────┤
│  Express.js Backend (Node.js / TypeScript)             │
│                                                         │
│  ┌─────────────────┐  ┌─────────────────┐             │
│  │ AI Service      │  │ Auth Service    │             │
│  └─────────────────┘  └─────────────────┘             │
│  ┌─────────────────┐  ┌─────────────────┐             │
│  │ Credential Svc  │  │ Zero-Trust Svc  │             │
│  └─────────────────┘  └─────────────────┘             │
│  ┌─────────────────┐  ┌─────────────────┐             │
│  │ Vault Service   │  │ Job Service     │             │
│  └─────────────────┘  └─────────────────┘             │
└──┬──────────────────────────────────┬──────────────────┘
   │                                  │
   ▼                                  ▼
┌──────────────────┐       ┌──────────────────┐
│  Data Layer      │       │  Message Queue   │
├──────────────────┤       ├──────────────────┤
│ PostgreSQL       │       │  Bull Queue      │
│ • Users          │       │  • Job Queue     │
│ • Jobs           │       │  • Notifications │
│ • Credentials    │       │  • Events        │
│ • Audit Logs     │       └──────────────────┘
└────────┬─────────┘              │
         │                        ▼
         │             ┌──────────────────┐
         │             │ Background Jobs  │
         │             │ • Processing     │
         │             │ • Remediation    │
         │             │ • Analytics      │
         │             └──────────────────┘
         │
         ▼
┌──────────────────┐
│  Cache Layer     │
├──────────────────┤
│  Redis           │
│  • Sessions      │
│  • Cache         │
│  • Temp Data     │
└──────────────────┘
```

## Frontend Architecture

```
┌─────────────────────────────────────────┐
│      React Frontend (Vite)              │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Pages & Routes                  │  │
│  │  • Dashboard                     │  │
│  │  • Jobs                          │  │
│  │  • Settings                      │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Components                      │  │
│  │  • Layout                        │  │
│  │  • Forms                         │  │
│  │  • Charts (Recharts)             │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  State Management (TanStack Qry) │  │
│  │  • Server State                  │  │
│  │  • Cache Management              │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Services                        │  │
│  │  • API Client (Axios)            │  │
│  │  • WebSocket (Socket.IO)         │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
         │
         │ HTTP / WebSocket
         ▼
   Backend API
```

## Backend Architecture

```
┌─────────────────────────────────────────────┐
│      Express.js Backend                     │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  Routes Layer                        │  │
│  │  • HTTP Endpoints                    │  │
│  │  • WebSocket Handlers                │  │
│  └──────────────────────────────────────┘  │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────────────────────────┐  │
│  │  Middleware                          │  │
│  │  • Authentication (JWT)              │  │
│  │  • Zero-Trust Validation             │  │
│  │  • Rate Limiting                     │  │
│  │  • Error Handling                    │  │
│  │  • Logging                           │  │
│  └──────────────────────────────────────┘  │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────────────────────────┐  │
│  │  Controllers                         │  │
│  │  • Request Handling                  │  │
│  │  • Response Formatting               │  │
│  └──────────────────────────────────────┘  │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────────────────────────┐  │
│  │  Services                            │  │
│  │  • AI Service                        │  │
│  │  • Auth Service                      │  │
│  │  • Credential Service                │  │
│  │  • Vault Service                     │  │
│  │  • Zero-Trust Service                │  │
│  │  • Job Service                       │  │
│  └──────────────────────────────────────┘  │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────────────────────────┐  │
│  │  Data Access Layer                   │  │
│  │  • Database Queries                  │  │
│  │  • ORM / Query Builder               │  │
│  │  • Connection Pooling                │  │
│  └──────────────────────────────────────┘  │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────────────────────────┐  │
│  │  External Integrations               │  │
│  │  • OpenAI API                        │  │
│  │  • Vault Service                     │  │
│  │  • Cloud Providers                   │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

## Data Flow Diagram

```
User Request
    │
    ▼
Frontend (React)
    │
    ├──► HTTP GET/POST
    │
    ▼
Nginx (Reverse Proxy)
    │
    ├──► Load Balancing
    ├──► TLS Termination
    │
    ▼
Express API
    │
    ├──► Middleware Processing
    │    • Authentication
    │    • Validation
    │    • Rate Limiting
    │
    ▼
Route Handler
    │
    ├──► Controller
    │
    ▼
Service Layer
    │
    ├──► Business Logic
    │    • AI Analysis
    │    • Job Processing
    │    • Authorization
    │
    ├──────┬──────────────┐
    │      │              │
    ▼      ▼              ▼
Database Queue   External Service
    │      │              │
    │      ├──► Background Job
    │      │
    ▼      ▼
Response
    │
    ▼
Frontend Update
    │
    ▼
User Sees Result
```

## Deployment Architecture

```
┌──────────────────────────────────────────────────────┐
│        Kubernetes Cluster / Docker Compose          │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌────────────────┐       ┌────────────────┐       │
│  │  Frontend Pod  │       │  Backend Pod   │       │
│  │  (React)       │◄─────►│  (Node.js)     │       │
│  └────────────────┘       └────────────────┘       │
│         │                         │                 │
│         └──────────┬──────────────┘                 │
│                    │                                │
│                    ▼                                │
│         ┌────────────────────┐                     │
│         │  Ingress / Service │                     │
│         └────────────────────┘                     │
│                    │                                │
│      ┌─────────────┼─────────────┐                 │
│      │             │             │                 │
│      ▼             ▼             ▼                 │
│  ┌────────┐  ┌────────┐   ┌─────────────┐        │
│  │  PVC   │  │ Config │   │  Secrets    │        │
│  │(Storage)│ │  Maps  │   │             │        │
│  └────────┘  └────────┘   └─────────────┘        │
│                                                      │
│  ┌────────────────────────────────────────┐        │
│  │   Persistent Volumes                   │        │
│  │  • PostgreSQL Data                     │        │
│  │  • Redis Storage                       │        │
│  └────────────────────────────────────────┘        │
│                                                      │
└──────────────────────────────────────────────────────┘
         │
         │ Cloud Provider (AWS/Azure/GCP)
         │
         ▼
    ┌─────────────┐
    │   Cloud     │
    │  Services   │
    │  • DNS      │
    │  • Storage  │
    │  • Secrets  │
    └─────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────┐
│     Zero-Trust Security Architecture        │
├─────────────────────────────────────────────┤
│                                             │
│  Entry Points:                              │
│  ┌─────────────────────────────────────┐   │
│  │  • TLS/HTTPS (443)                  │   │
│  │  • Certificate Validation           │   │
│  │  • Security Headers (Helmet)        │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Authentication:                            │
│  ┌─────────────────────────────────────┐   │
│  │  • JWT Tokens                       │   │
│  │  • bcrypt Password Hashing          │   │
│  │  • Multi-factor (Ready)             │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Authorization:                             │
│  ┌─────────────────────────────────────┐   │
│  │  • Role-Based Access Control (RBAC) │   │
│  │  • Policy-Based Rules               │   │
│  │  • Resource-Level Permissions       │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Secret Management:                         │
│  ┌─────────────────────────────────────┐   │
│  │  • Vault Integration                │   │
│  │  • Encrypted Storage                │   │
│  │  • Rotation Policies                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Audit & Logging:                           │
│  ┌─────────────────────────────────────┐   │
│  │  • Audit Trail                      │   │
│  │  • Winston Logging                  │   │
│  │  • Compliance Tracking              │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

## CI/CD Pipeline

```
Git Repository
    │
    ├──► Push to main
    │
    ▼
GitHub Actions
    │
    ├──► Lint & Format Check
    ├──► Security Scanning (SAST)
    ├──► Dependency Check
    ├──► Unit Tests
    ├──► Integration Tests
    │
    ├──► Build Docker Images
    │    ├──► Frontend
    │    ├──► Backend
    │
    ├──► Push to Registry
    │
    ├──► Deploy to Staging
    │
    ├──► Smoke Tests
    │
    ├──► Deploy to Production
    │
    ▼
Monitoring & Alerts
```

---

## Reference

Generated using GitDiagram for visual repository understanding.
Visit https://gitdiagram.com/ for more information.
EOF
    
    print_success "Architecture diagrams saved to $arch_file"
}

# Generate development workflow diagram
generate_workflow_diagram() {
    print_header "Generating Development Workflow"
    
    local workflow_file="$OUTPUT_DIR/development-workflow.md"
    
    cat > "$workflow_file" << 'EOF'
# Development Workflow

## Local Development Setup

```
┌──────────────────────────────────────────┐
│  Developer Machine                       │
├──────────────────────────────────────────┤
│                                          │
│  Clone Repository                        │
│  git clone [repo-url]                    │
│          │                               │
│          ▼                               │
│  Install Pre-commit Hooks                │
│  ./scripts/setup-pre-commit.sh           │
│          │                               │
│          ▼                               │
│  Install Dependencies                    │
│  cd backend && npm install               │
│  cd frontend && npm install              │
│          │                               │
│          ▼                               │
│  Start Development Servers               │
│  Backend: npm run dev                    │
│  Frontend: npm run dev                   │
│          │                               │
│          ▼                               │
│  Or Use Docker Compose                   │
│  docker-compose -f docker-compose.dev   │
│          │                               │
│          ▼                               │
│  Access Application                      │
│  Frontend: http://localhost:3000         │
│  Backend: http://localhost:3001/api      │
│                                          │
└──────────────────────────────────────────┘
```

## Feature Development Flow

```
1. Create Feature Branch
   git checkout -b feature/my-feature

2. Make Changes
   ├──► Modify code
   ├──► Write tests
   ├──► Update docs

3. Pre-commit Hook Runs (Automated)
   ├──► Lint check
   ├──► Format check
   ├──► Security scan
   ├──► Type check

4. Run Tests Locally
   ├──► npm run test:unit
   ├──► npm run test:integration
   └──► npm run type-check

5. Commit Changes
   git commit -m "feat: description"

6. Push to Remote
   git push origin feature/my-feature

7. Create Pull Request
   └──► GitHub PR

8. CI/CD Runs (Automated)
   ├──► Lint
   ├──► Tests
   ├──► Security
   ├──► Build Docker Images

9. Code Review
   └──► Approved

10. Merge to Main
    ├──► Automated tests run
    └──► Deploy to staging

11. Deployment to Production
    └──► Manual approval (if needed)
```

## Testing Strategy

```
Test Pyramid
          ▲
         /|\
        / | \
       /  E  \  E2E Tests (10%)
      /   2   \  ├─ Full workflow
     /    E    \ └─ User scenarios
    /__________\
       /    \
      /  I   \  Integration Tests (30%)
     / Test  \ ├─ Service interactions
    /__I_____\ └─ API endpoints
      /      \
     / Unit  \ Unit Tests (60%)
    / Tests  / ├─ Functions
   /________/ ├─ Classes
             └─ Components
```

## Release Process

```
┌──────────────────────────────────────────┐
│      Release Preparation                 │
├──────────────────────────────────────────┤
│                                          │
│ 1. Create Release Branch                 │
│    git checkout -b release/v1.x.x        │
│                                          │
│ 2. Update Version Numbers                │
│    ├──► package.json                    │
│    ├──► CHANGELOG.md                    │
│    └──► docs                            │
│                                          │
│ 3. Run Full Test Suite                   │
│    npm run test:ci                      │
│                                          │
│ 4. Security Audit                        │
│    npm audit                            │
│                                          │
│ 5. Build Release Artifacts               │
│    npm run build                        │
│    docker build -t app:v1.x.x .         │
│                                          │
│ 6. Tag Release                           │
│    git tag -a v1.x.x                    │
│                                          │
│ 7. Create GitHub Release                 │
│    └──► Add release notes                │
│                                          │
│ 8. Deploy to Production                  │
│    ├──► Update infrastructure           │
│    ├──► Run smoke tests                 │
│    └──► Monitor metrics                 │
│                                          │
└──────────────────────────────────────────┘
```

---

Generated using GitDiagram workflow visualization.
EOF
    
    print_success "Development workflow saved to $workflow_file"
}

# Generate database schema diagram
generate_database_diagram() {
    print_header "Generating Database Schema"
    
    local db_file="$OUTPUT_DIR/database-schema.md"
    
    cat > "$db_file" << 'EOF'
# Database Schema

## Entity Relationship Diagram

```
┌─────────────────┐
│     Users       │
├─────────────────┤
│ id (PK)         │
│ email           │
│ password_hash   │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │
         │ 1:N
         │
         ▼
┌──────────────────────┐       ┌────────────────────┐
│       Jobs           │◄──────│  JobExecutions     │
├──────────────────────┤ N  1  ├────────────────────┤
│ id (PK)              │       │ id (PK)            │
│ user_id (FK)         │       │ job_id (FK)        │
│ name                 │       │ status             │
│ status               │       │ started_at         │
│ created_at           │       │ completed_at       │
│ updated_at           │       │ result             │
└──────────────────────┘       └────────────────────┘

┌────────────────────┐
│   Credentials      │
├────────────────────┤
│ id (PK)            │
│ user_id (FK)       │
│ type               │
│ encrypted_value    │
│ created_at         │
└────────────────────┘

┌────────────────────┐
│  AuditLogs         │
├────────────────────┤
│ id (PK)            │
│ user_id (FK)       │
│ action             │
│ resource_type      │
│ resource_id        │
│ timestamp          │
│ details            │
└────────────────────┘

┌────────────────────┐
│   AIModels         │
├────────────────────┤
│ id (PK)            │
│ name               │
│ version            │
│ model_type         │
│ deployed           │
│ created_at         │
└────────────────────┘
```

## Table Relationships

- **Users** → **Jobs**: One user has many jobs
- **Jobs** → **JobExecutions**: One job has many executions
- **Users** → **Credentials**: One user has many credentials
- **Users** → **AuditLogs**: One user has many audit logs

---

Generated using GitDiagram database visualization.
EOF
    
    print_success "Database schema saved to $db_file"
}

# Create GitDiagram reference document
generate_gitdiagram_reference() {
    print_header "Generating GitDiagram Reference"
    
    local ref_file="$OUTPUT_DIR/gitdiagram-reference.md"
    
    cat > "$ref_file" << 'EOF'
# GitDiagram Integration Guide

## Overview

GitDiagram (https://gitdiagram.com/) provides visual repository analysis and architecture documentation.

## Integration Points

### 1. Repository Analysis
- **URL**: `https://gitdiagram.com/repo/sbusanelli/AutoMind`
- **Provides**: 
  - File structure visualization
  - Dependency graphs
  - Code complexity metrics
  - Architecture overview

### 2. Automated Diagrams
- Generate architecture diagrams
- Visualize file relationships
- Show dependency flow
- Map module interactions

### 3. Documentation Integration
All generated diagrams are stored in:
```
docs/diagrams/
├── architecture-diagrams.md
├── development-workflow.md
├── database-schema.md
├── repository-tree.txt
└── gitdiagram-reference.md
```

## Using GitDiagram

### Web Interface
1. Visit: https://gitdiagram.com/
2. Enter: `sbusanelli/AutoMind`
3. Explore interactive visualizations

### API Integration (if available)
```bash
# Generate diagram and save as image
curl -X POST https://gitdiagram.com/api/diagram \
  -d "repo=sbusanelli/AutoMind" \
  -o diagram.png
```

## Updating Diagrams

### Automatic Updates
The `generate-diagrams.sh` script automatically regenerates diagrams when:
- Repository structure changes
- New major components added
- Architecture documentation needs refresh

### Manual Updates
```bash
# Regenerate all diagrams
./scripts/generate-diagrams.sh

# Push updates
git add docs/diagrams/
git commit -m "docs: update architecture diagrams"
git push origin main
```

## Benefits for New Developers

1. **Quick Onboarding**: Visual understanding of project structure
2. **Architecture Overview**: See how components interact
3. **Dependency Mapping**: Understand module relationships
4. **Best Practices**: Learn from structured visualization
5. **Documentation**: Reference while coding

## GitDiagram Features

### Repository Visualization
- **File Tree**: Hierarchical structure view
- **Module Dependencies**: Show component relationships
- **Code Metrics**: Complexity analysis
- **Hotspots**: Identify frequently changed files

### Architecture Analysis
- **Component Diagrams**: Service relationships
- **Data Flow**: Information flow mapping
- **Integration Points**: External service connections
- **Security Zones**: Trust boundaries

### Collaboration
- **Share Diagrams**: Generate shareable links
- **Export Options**: PNG, SVG, PDF formats
- **Comments**: Annotate diagrams
- **Version Control**: Track diagram changes

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Generate Architecture Diagrams
  run: ./scripts/generate-diagrams.sh

- name: Commit Diagrams
  run: |
    git add docs/diagrams/
    git commit -m "docs: update diagrams" || true
    git push
```

## Resources

- **GitDiagram Website**: https://gitdiagram.com/
- **Documentation**: https://gitdiagram.com/docs/
- **API Reference**: https://gitdiagram.com/api/docs/
- **Examples**: https://gitdiagram.com/examples/

## Related Documentation

- See [project-structure.md](./project-structure.md) for detailed structure
- See [architecture-diagrams.md](./diagrams/architecture-diagrams.md) for full diagrams
- See [development-workflow.md](./diagrams/development-workflow.md) for workflow details

---

Last updated: $(date)
Generated by: generate-diagrams.sh
EOF
    
    print_success "GitDiagram reference saved to $ref_file"
}

# Create index of all diagrams
generate_diagrams_index() {
    print_header "Creating Diagrams Index"
    
    local index_file="$OUTPUT_DIR/README.md"
    
    cat > "$index_file" << 'EOF'
# Architecture Diagrams & Documentation

This directory contains generated architecture diagrams and visual documentation for the AutoMind repository.

## Contents

### 📊 Diagrams
- **[architecture-diagrams.md](./architecture-diagrams.md)** - System, frontend, backend, and deployment architecture
- **[development-workflow.md](./development-workflow.md)** - Development process and CI/CD pipeline
- **[database-schema.md](./database-schema.md)** - Database structure and relationships
- **[repository-tree.txt](./repository-tree.txt)** - Complete file structure

### 📚 Reference
- **[gitdiagram-reference.md](./gitdiagram-reference.md)** - GitDiagram integration guide

## Quick Links

### For New Developers
1. Start with: [Architecture Diagrams](./architecture-diagrams.md)
2. Understand workflow: [Development Workflow](./development-workflow.md)
3. Learn data structure: [Database Schema](./database-schema.md)
4. Review structure: [Project Structure](../project-structure.md)

### For DevOps/Infrastructure
- See deployment architecture: [architecture-diagrams.md](./architecture-diagrams.md#deployment-architecture)
- Review CI/CD: [development-workflow.md](./development-workflow.md#cicd-pipeline)
- Check security: [architecture-diagrams.md](./architecture-diagrams.md#security-architecture)

### For Backend Developers
- Backend architecture: [architecture-diagrams.md](./architecture-diagrams.md#backend-architecture)
- Data flow: [architecture-diagrams.md](./architecture-diagrams.md#data-flow-diagram)
- Database schema: [database-schema.md](./database-schema.md)

### For Frontend Developers
- Frontend architecture: [architecture-diagrams.md](./architecture-diagrams.md#frontend-architecture)
- Data flow: [architecture-diagrams.md](./architecture-diagrams.md#data-flow-diagram)

## Viewing Diagrams

All diagrams are in Markdown format with ASCII art for easy viewing:
- In GitHub: Rendered automatically
- In your editor: Plain text view
- In your IDE: Markdown preview

## Updating Diagrams

To regenerate all diagrams:
```bash
./scripts/generate-diagrams.sh
```

This will update all diagram files in this directory.

## GitDiagram Integration

This project uses **[GitDiagram](https://gitdiagram.com/)** for visual repository analysis.

- **Live View**: https://gitdiagram.com/repo/sbusanelli/AutoMind
- **Learn More**: https://gitdiagram.com/docs/

## Related Documentation

- [Project Structure](../project-structure.md) - Detailed folder and file organization
- [Zero-Trust Architecture](../zero-trust-architecture.md) - Security design
- [Testing Guide](../testing-guide.md) - Test strategies and examples
- [Security Best Practices](../security-best-practices.md) - Security guidelines

---

Generated by: `scripts/generate-diagrams.sh`
Last updated: See git history
EOF
    
    print_success "Diagrams index created at $index_file"
}

# Main execution
main() {
    print_header "AutoMind GitDiagram Generator"
    
    # Check dependencies
    check_dependencies
    
    # Setup directories
    setup_output_dir
    
    # Generate all diagrams
    generate_tree_diagram
    generate_architecture_diagrams
    generate_workflow_diagram
    generate_database_diagram
    generate_gitdiagram_reference
    generate_diagrams_index
    
    print_header "✓ Diagram Generation Complete!"
    
    print_info "Generated diagrams:"
    echo "  • $OUTPUT_DIR/architecture-diagrams.md"
    echo "  • $OUTPUT_DIR/development-workflow.md"
    echo "  • $OUTPUT_DIR/database-schema.md"
    echo "  • $OUTPUT_DIR/repository-tree.txt"
    echo "  • $OUTPUT_DIR/gitdiagram-reference.md"
    echo "  • $OUTPUT_DIR/README.md"
    
    print_info "Next steps:"
    echo "  1. Review diagrams: cd docs/diagrams && ls -la"
    echo "  2. View in browser: open docs/diagrams/README.md"
    echo "  3. Visit GitDiagram: https://gitdiagram.com/repo/sbusanelli/AutoMind"
    echo "  4. Commit changes: git add docs/diagrams/ && git commit -m 'docs: add architecture diagrams'"
    
    print_success "Done!"
}

# Run main function
main
