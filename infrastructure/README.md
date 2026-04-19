# AutoMind AWS EKS Infrastructure

This directory contains all the infrastructure configuration for deploying AutoMind on AWS EKS (Elastic Kubernetes Service).

## Overview

AutoMind is designed to run on AWS EKS with a complete cloud-native architecture including:

- **EKS Cluster**: Managed Kubernetes service
- **VPC & Networking**: Isolated network with public/private subnets
- **Load Balancing**: Application Load Balancer with SSL termination
- **Database**: PostgreSQL with persistent storage
- **Cache**: Redis for session management and caching
- **Monitoring**: Prometheus, Grafana, and CloudWatch integration
- **Auto-scaling**: Horizontal Pod Autoscaling for high availability
- **Security**: Network policies, IAM roles, and secrets management

## Architecture

```
Internet Gateway
       |
    Load Balancer (ALB)
       |
    Ingress Controller
       |
    AutoMind Services
       |
    - Frontend (React)
    - Backend (Node.js)
    - Database (PostgreSQL)
    - Cache (Redis)
```

## Directory Structure

```
infrastructure/
|-- aws/                          # AWS CloudFormation templates
|   |-- eks-cloudformation.yml    # EKS cluster and VPC
|   |-- iam-roles.yaml            # IAM roles for service accounts
|   `-- cloudformation.yml       # Legacy ECS template
|-- kubernetes/                   # Kubernetes manifests
|   |-- namespace.yaml            # Namespaces
|   |-- configmap.yaml            # Configuration
|   |-- secret.yaml               # Secrets
|   |-- postgres.yaml             # PostgreSQL deployment
|   |-- redis.yaml                # Redis deployment
|   |-- backend.yaml              # Backend service
|   |-- frontend.yaml             # Frontend service
|   |-- service-account.yaml      # Service accounts
|   |-- ingress.yaml              # ALB ingress
|   |-- hpa.yaml                  # Horizontal Pod Autoscaling
|   |-- monitoring.yaml           # Service monitors
|   `-- network-policy.yaml      # Network security
|-- scripts/                      # Deployment and utility scripts
|   |-- deploy-eks.sh            # Main deployment script
|   |-- cleanup-eks.sh           # Cleanup script
|   `-- build-and-push.sh        # Docker build and push
`-- docker/                      # Docker configuration
    |-- docker-compose.yml       # Local development
    `-- Dockerfile.*             # Dockerfiles
```

## Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **kubectl** installed
3. **Docker** installed and running
4. **Helm** (optional, for additional services)

### 1. Build and Push Docker Images

```bash
# Build and push latest images
./infrastructure/scripts/build-and-push.sh latest

# Or build with version tag
./infrastructure/scripts/build-and-push.sh v1.0.0
```

### 2. Deploy to EKS

```bash
# Deploy to staging environment
./infrastructure/scripts/deploy-eks.sh staging

# Deploy to production environment
./infrastructure/scripts/deploy-eks.sh production
```

### 3. Access AutoMind

The deployment script will output the Load Balancer URL. Access AutoMind at:

```
http://<load-balancer-dns-name>
```

## Configuration

### Environment Variables

Key configuration options in the manifests:

| Variable | Description | Default |
|----------|-------------|---------|
| `ENVIRONMENT` | Deployment environment | `staging` |
| `NODE_ENV` | Node.js environment | `staging` |
| `DB_HOST` | PostgreSQL hostname | `automind-postgres` |
| `REDIS_HOST` | Redis hostname | `automind-redis` |
| `JWT_EXPIRES_IN` | JWT token expiration | `7d` |
| `LOG_LEVEL` | Logging level | `info` |

### Scaling Configuration

- **Backend**: 2-10 replicas (HPA)
- **Frontend**: 2-6 replicas (HPA)
- **Database**: 1 replica (StatefulSet)
- **Redis**: 1 replica (Deployment)

### Resource Limits

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|-----------------|--------------|
| Backend | 250m | 500m | 512Mi | 1Gi |
| Frontend | 100m | 200m | 128Mi | 256Mi |
| PostgreSQL | 250m | 500m | 256Mi | 512Mi |
| Redis | 100m | 200m | 128Mi | 256Mi |

## Monitoring and Logging

### Built-in Monitoring

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **CloudWatch**: AWS service metrics
- **Health Checks**: Application and infrastructure health

### Log Aggregation

- **Application Logs**: Structured JSON logging
- **Access Logs**: Nginx and application access logs
- **System Logs**: Kubernetes events and pod logs

### Alerting

Configure alerts for:
- High error rates
- Memory/CPU thresholds
- Database connection issues
- Pod restarts

## Security

### Network Security

- **VPC Isolation**: Private subnets for applications
- **Security Groups**: Restrictive ingress/egress rules
- **Network Policies**: Kubernetes network policies
- **TLS/SSL**: End-to-end encryption

### Access Control

- **IAM Roles**: Service account IAM integration
- **RBAC**: Kubernetes role-based access control
- **Secrets Management**: AWS Secrets Manager integration
- **Pod Security**: Non-root containers, security contexts

### Compliance

- **OWASP**: Security best practices
- **CIS Benchmarks**: Kubernetes security standards
- **GDPR**: Data protection compliance
- **SOC 2**: Security and availability controls

## Disaster Recovery

### Backup Strategy

- **Database Backups**: Automated daily snapshots
- **EBS Snapshots**: Volume backups
- **Cross-Region Replication**: Multi-region deployment
- **Application State**: Stateless design for easy recovery

### Recovery Procedures

1. **Infrastructure Recovery**: CloudFormation templates
2. **Data Recovery**: Database snapshots and restores
3. **Application Recovery**: Container orchestration
4. **DNS Recovery**: Route53 failover

## Cost Optimization

### Resource Optimization

- **Right Sizing**: Appropriate instance types
- **Auto-scaling**: Scale based on demand
- **Spot Instances**: Cost-effective compute
- **Reserved Instances**: Long-term discounts

### Monitoring Costs

- **Cost Explorer**: AWS cost analysis
- **Budgets**: Spending alerts
- **Resource Tags**: Cost allocation
- **Usage Reports**: Regular optimization

## Troubleshooting

### Common Issues

1. **Pod Not Starting**
   ```bash
   kubectl describe pod <pod-name> -n automind
   kubectl logs <pod-name> -n automind
   ```

2. **Service Not Accessible**
   ```bash
   kubectl get svc -n automind
   kubectl get ingress -n automind
   ```

3. **Database Connection Issues**
   ```bash
   kubectl exec -it postgres-pod -n automind -- psql -U postgres
   ```

4. **High Memory Usage**
   ```bash
   kubectl top pods -n automind
   kubectl describe hpa -n automind
   ```

### Debug Commands

```bash
# Check cluster status
kubectl cluster-info

# Check node status
kubectl get nodes

# Check pod status
kubectl get pods -n automind -o wide

# Check service status
kubectl get svc -n automind

# Check events
kubectl get events -n automind --sort-by='.lastTimestamp'

# Port forward for debugging
kubectl port-forward svc/automind-backend 5000:5000 -n automind
```

## Maintenance

### Regular Tasks

- **Updates**: Kubernetes version upgrades
- **Patches**: Security patches and updates
- **Backups**: Verify backup procedures
- **Monitoring**: Check alert thresholds
- **Cost Review**: Optimize resource usage

### Rollback Procedures

```bash
# Rollback deployment
kubectl rollout undo deployment/automind-backend -n automind

# Check rollback status
kubectl rollout status deployment/automind-backend -n automind
```

## Support

### Documentation

- [AutoMind Wiki](../../wiki/)
- [API Reference](../../wiki/API-Reference.md)
- [Security Guidelines](../../wiki/Security-Guidelines.md)

### Contact

- **Issues**: [GitHub Issues](https://github.com/sbusanelli/AutoMind/issues)
- **Documentation**: [Wiki](https://github.com/sbusanelli/AutoMind/wiki)
- **Support**: Create GitHub issue with detailed information

---

**Note**: This infrastructure is designed for production workloads with high availability, security, and scalability requirements. Adjust configurations based on your specific needs and environment.
