# Deployment Guide

## 🚀 Production Deployment

### Prerequisites
- **Infrastructure**: AWS/GCP/Azure account with appropriate permissions
- **Domain**: Custom domain for SSL certificates
- **Monitoring**: Alerting system configured
- **Security**: SSL certificates and firewall rules

### Environment Setup

#### 1. Infrastructure Preparation
```bash
# Create production environment variables
export NODE_ENV=production
export DATABASE_URL=postgresql://prod_user:prod_pass@prod-db:5432/flowops
export REDIS_URL=redis://prod-redis:6379
export JWT_SECRET=your_production_jwt_secret_here
export OPENAI_API_KEY=your_production_openai_key_here
```

#### 2. Database Migration
```bash
# Run database migrations
cd backend
npm run db:migrate

# Seed production data if needed
npm run db:seed
```

### Docker Deployment

#### Build Images
```bash
# Build backend image
cd backend
docker build -t flowops-backend:latest .

# Build frontend image
cd ../frontend
docker build -t flowops-frontend:latest .
```

#### Production Docker Compose
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  backend:
    image: flowops-backend:latest
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - JWT_SECRET=${JWT_SECRET}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  frontend:
    image: flowops-frontend:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/ssl
    depends_on:
      - backend
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=flowops
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - frontend
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

#### Deploy with Docker
```bash
# Deploy all services
docker-compose -f docker-compose.prod.yml up -d

# Check service status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Kubernetes Deployment

#### Namespace and ConfigMaps
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: flowops-prod

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: flowops-config
  namespace: flowops-prod
data:
  NODE_ENV: "production"
  API_BASE_URL: "https://api.flowops.com"
```

#### Secrets Management
```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: flowops-secrets
  namespace: flowops-prod
type: Opaque
data:
  DATABASE_URL: <base64-encoded-db-url>
  REDIS_URL: <base64-encoded-redis-url>
  JWT_SECRET: <base64-encoded-jwt-secret>
  OPENAI_API_KEY: <base64-encoded-openai-key>
```

#### Application Deployment
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flowops-backend
  namespace: flowops-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flowops-backend
  template:
    metadata:
      labels:
        app: flowops-backend
    spec:
      containers:
      - name: backend
        image: flowops-backend:latest
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: flowops-config
        - secretRef:
            name: flowops-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### Service and Ingress
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: flowops-backend-service
  namespace: flowops-prod
spec:
  selector:
    app: flowops-backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP

---
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flowops-ingress
  namespace: flowops-prod
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - api.flowops.com
    - flowops.com
    secretName: flowops-tls
  rules:
  - host: api.flowops.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flowops-backend-service
            port:
              number: 80
  - host: flowops.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flowops-frontend-service
            port:
              number: 80
```

#### Deploy to Kubernetes
```bash
# Apply all configurations
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Check deployment status
kubectl get pods -n flowops-prod
kubectl get services -n flowops-prod
kubectl get ingress -n flowops-prod

# Scale deployment if needed
kubectl scale deployment flowops-backend --replicas=5 -n flowops-prod
```

### Cloud-Specific Deployments

#### AWS ECS Deployment
```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name flowops-prod

# Create task definition
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json

# Create service
aws ecs create-service \
  --cluster flowops-prod \
  --service-name flowops-backend \
  --task-definition flowops-task \
  --desired-count 3 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-123],securityGroups=[sg-123],assignPublicIp=ENABLED}"
```

#### Google Cloud Run Deployment
```bash
# Build and deploy to Cloud Run
gcloud builds submit --tag gcr.io/PROJECT_ID/flowops-backend

# Deploy service
gcloud run deploy flowops-backend \
  --image gcr.io/PROJECT_ID/flowops-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1
```

#### Azure Container Instances
```bash
# Create resource group
az group create --name flowops-rg --location eastus

# Create container registry
az acr create --resource-group flowops-rg --name flowopsacr --sku Basic

# Build and push image
az acr build --registry flowopsacr --image flowops-backend .

# Deploy container instance
az container create \
  --resource-group flowops-rg \
  --name flowops-backend \
  --image flowopsacr.azurecr.io/flowops-backend:latest \
  --cpu 1 \
  --memory 2
```

### Monitoring and Logging

#### Health Checks
```bash
# Application health endpoint
curl https://api.flowops.com/health

# Kubernetes pod health
kubectl get pods -n flowops-prod --field-selector=status.phase=Running

# Service logs
kubectl logs -f deployment/flowops-backend -n flowops-prod
```

#### Monitoring Setup
```yaml
# monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'flowops'
        static_configs:
          - targets: ['flowops-backend-service:80']
```

#### Alerting Rules
```yaml
# monitoring/alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: AlertmanagerConfig
metadata:
  name: flowops-alerts
spec:
  route:
    group_by: ['alertname']
    group_wait: 10s
    group_interval: 10s
    receiver: 'web.hook'
  receivers:
  - name: 'web.hook'
    webhook_configs:
    - url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
```

### SSL/TLS Configuration

#### Let's Encrypt Certificates
```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml

# Create cluster issuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Backup and Recovery

#### Database Backups
```bash
# Automated daily backups
kubectl create cronjob flowops-db-backup \
  --image=postgres:15 \
  --schedule="0 2 * * *" \
  --namespace=flowops-prod \
  -- ./backup-script.sh

# Backup script
#!/bin/bash
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql
aws s3 cp backup-$(date +%Y%m%d).sql s3://flowops-backups/
```

#### Application State Backups
```bash
# Kubernetes volume snapshots
kubectl create -f - <<EOF
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: flowops-data-snapshot
spec:
  volumeSnapshotClassName: csi-hostpath-snapshot
  source:
    persistentVolumeClaimName: flowops-data-pvc
EOF
```

### Rollback Procedures

#### Quick Rollback
```bash
# Docker rollback
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --force-recreate

# Kubernetes rollback
kubectl rollout undo deployment/flowops-backend -n flowops-prod
kubectl rollout status deployment/flowops-backend -n flowops-prod
```

#### Full Recovery
```bash
# Restore from backup
kubectl exec -it postgres-pod -n flowops-prod -- psql -U postgres -d flowops < backup-20260410.sql

# Restore application state
kubectl apply -f k8s/previous-version-deployment.yaml
```

## 🔒 Security Considerations

### Production Security Checklist
- [ ] Environment variables are properly secured
- [ ] SSL/TLS certificates are valid
- [ ] Firewall rules are restrictive
- [ ] Database access is limited
- [ ] API rate limiting is enabled
- [ ] Monitoring and alerting are active
- [ ] Backup procedures are tested
- [ ] Rollback procedures are documented

### Security Headers
```nginx
# nginx.conf
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'";
```

---

**Last Updated**: 2026-04-10  
**Version**: 1.0.0
