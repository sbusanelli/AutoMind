# FlowOps - AI-Powered Workflow Operations

A production-ready AI-powered workflow operations system built with modern full-stack architecture and comprehensive agentic AI capabilities.

## 🏗️ Architecture

### Technology Stack
- **Frontend**: React 18 + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + TypeScript  
- **Database**: PostgreSQL + Redis (caching)
- **Queue**: Redis + Bull Queue
- **Authentication**: JWT + bcrypt
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions with security scanning
- **Monitoring**: Prometheus + Grafana
- **Logging**: Winston + ELK Stack

### System Design
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend    │    │    Backend     │    │   Database      │
│   (React)      │◄──►│   (Node.js)    │◄──►│  (PostgreSQL)   │
│                │    │                │    │                │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────►│   Redis Queue   │◄─────────────┘
                        │ (Bull Queue)   │
                        └─────────────────┘
```

## 🚀 Features

### Core Functionality
- **AI-Powered Job Optimization**: Intelligent job scheduling and resource allocation
- **Predictive Analytics**: ML-based failure prediction and anomaly detection
- **Natural Language Interface**: Chat with AI for workflow management
- **Real-time Updates**: WebSocket notifications with AI insights
- **Automated Performance Tuning**: AI-driven system optimization
- **Smart Resource Management**: Dynamic resource allocation based on AI analysis

### AI Capabilities
- **Job Optimization**: AI analyzes job patterns and suggests optimal scheduling
- **Failure Prediction**: ML models predict potential job failures before they occur
- **Performance Insights**: Real-time AI analysis of system performance metrics
- **Natural Language Queries**: Ask questions about your workflow in plain English
- **Anomaly Detection**: AI identifies unusual patterns and potential issues
- **Automated Remediation**: AI suggests and can automatically fix common issues

### Security Features
- **Authentication**: JWT-based with refresh tokens
- **Authorization**: Role-based access control (RBAC)
- **Input Validation**: Comprehensive request validation
- **Rate Limiting**: API abuse prevention
- **CORS**: Proper cross-origin configuration
- **Security Headers**: OWASP recommended headers
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Input sanitization and CSP

## 📁 Project Structure

```
scheduledbatch/
├── frontend/                    # React TypeScript application
│   ├── src/
│   │   ├── components/         # Reusable UI components
│   │   ├── pages/             # Page components
│   │   ├── hooks/             # Custom React hooks
│   │   ├── services/           # API services
│   │   ├── types/             # TypeScript definitions
│   │   └── utils/             # Utility functions
│   ├── public/
│   └── package.json
├── backend/                     # Node.js TypeScript API
│   ├── src/
│   │   ├── controllers/       # Route handlers
│   │   ├── services/          # Business logic
│   │   ├── models/            # Database models
│   │   ├── middleware/        # Express middleware
│   │   ├── routes/            # API routes
│   │   ├── jobs/              # Batch job definitions
│   │   ├── utils/             # Utility functions
│   │   └── config/            # Configuration
│   ├── tests/                 # Test suites
│   └── package.json
├── infrastructure/              # DevOps and deployment
│   ├── docker/
│   │   ├── Dockerfile.frontend
│   │   ├── Dockerfile.backend
│   │   └── docker-compose.yml
│   ├── kubernetes/            # K8s manifests
│   ├── terraform/             # Infrastructure as code
│   └── monitoring/           # Prometheus + Grafana
├── security/                   # Security configurations
│   ├── sast-config/          # Static analysis config
│   ├── dast-config/          # Dynamic analysis config
│   └── security-policies/     # Security policies
└── docs/                      # Documentation
    ├── api/                   # API documentation
    ├── deployment/             # Deployment guides
    └── security/              # Security analysis reports
```

## 🔧 Quick Start

### Prerequisites
- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 14+
- Redis 6+

### Development Setup
```bash
# Clone and setup
git clone https://github.com/sbusanelli/ScheduledBatch
cd ScheduledBatch

# Start infrastructure
docker-compose up -d

# Install dependencies
npm run install:all

# Run development servers
npm run dev
```

### Production Deployment
```bash
# Build and deploy
npm run build
docker-compose -f docker-compose.prod.yml up -d
```

## 🔒 Security Implementation

### Static Application Security Testing (SAST)
- **ESLint Security**: Security-focused linting rules
- **TypeScript**: Type safety for injection prevention
- **npm audit**: Dependency vulnerability scanning
- **Semgrep**: Custom security rule analysis
- **CodeQL**: Advanced static analysis

### Dynamic Application Security Testing (DAST)
- **OWASP ZAP**: Automated security scanning
- **Burp Suite**: Security testing integration
- **Postman**: Security test automation
- **Custom Scripts**: Input validation testing

### Security Headers
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: "1; mode=block"
Strict-Transport-Security: max-age=31536000
Content-Security-Policy: default-src 'self'
```

## 📊 Monitoring & Observability

### Metrics Collection
- **Application Metrics**: Request rate, error rate, response times
- **Business Metrics**: Job success rate, processing time
- **Infrastructure Metrics**: CPU, memory, disk usage
- **Security Metrics**: Authentication failures, blocked requests

### Logging Strategy
- **Structured Logging**: JSON format with correlation IDs
- **Log Levels**: Debug, Info, Warn, Error
- **Log Aggregation**: Centralized logging with ELK stack
- **Security Events**: Dedicated security log stream

## 🧪 Testing Strategy

### Unit Testing
- **Frontend**: Jest + React Testing Library
- **Backend**: Jest + Supertest
- **Coverage**: Minimum 80% code coverage

### Integration Testing
- **API Testing**: Postman collections
- **Database Testing**: Testcontainers
- **Queue Testing**: Redis test instance

### Security Testing
- **SAST**: Automated on every PR
- **DAST**: Weekly security scans
- **Penetration Testing**: Quarterly assessments

## 📈 Performance Optimization

### Frontend
- **Code Splitting**: Lazy loading with React.lazy
- **Bundle Optimization**: Webpack optimization
- **Caching**: Service worker implementation
- **CDN**: Static asset delivery

### Backend
- **Database Indexing**: Optimized query performance
- **Connection Pooling**: Efficient database connections
- **Caching Strategy**: Redis caching layer
- **Rate Limiting**: API abuse prevention

## 🚦 CI/CD Pipeline

### GitHub Actions Workflow
1. **Code Quality**: Linting, formatting, type checking
2. **Security Scanning**: SAST, dependency checks, secrets detection
3. **Testing**: Unit, integration, E2E tests
4. **Build**: Docker image creation and optimization
5. **Security Testing**: DAST scanning in staging
6. **Deployment**: Automated production deployment

### Environment Strategy
- **Development**: Feature branch deployments
- **Staging**: Production-like environment for testing
- **Production**: Blue-green deployment strategy

## 📚 API Documentation

### Authentication Endpoints
```
POST /api/auth/login
POST /api/auth/refresh
POST /api/auth/logout
```

### Job Management
```
GET    /api/jobs
POST   /api/jobs
GET    /api/jobs/:id
PUT    /api/jobs/:id
DELETE /api/jobs/:id
```

### AI Endpoints
```
POST   /api/ai/analyze/:jobId          # AI job optimization analysis
GET    /api/ai/predict-failures        # AI failure prediction
GET    /api/ai/performance-insights    # AI performance analysis
POST   /api/ai/optimize-schedule      # AI schedule optimization
GET    /api/ai/anomaly-alerts        # AI anomaly detection
POST   /api/ai/explain-failure/:id    # AI failure explanation
POST   /api/ai/chat                  # AI chat interface
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Ensure security checks pass
5. Submit pull request

## 📄 License

This project is licensed under the AGPL-3.0 License - see LICENSE file for details.

---

**Built by Sreedhar Busanelli** - Senior Systems Reliability Engineer at T-Mobile
