#!/bin/bash

# AutoMind EKS Deployment Script
# This script deploys AutoMind to AWS EKS

set -e

# Configuration
REGION="us-west-2"
ENVIRONMENT=${1:-staging}
CLUSTER_NAME="automind-${ENVIRONMENT}-eks"

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
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed. Please install it first."
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed. Please install it first."
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials are not configured. Please run 'aws configure'."
    fi
    
    log "Prerequisites check passed"
}

# Deploy CloudFormation stack
deploy_infrastructure() {
    log "Deploying CloudFormation infrastructure..."
    
    aws cloudformation deploy \
        --template-file infrastructure/aws/eks-cloudformation.yml \
        --stack-name automind-${ENVIRONMENT}-infrastructure \
        --parameter-overrides Environment=${ENVIRONMENT} \
        --capabilities CAPABILITY_IAM \
        --region ${REGION} \
        --no-fail-on-empty-changeset
    
    if [ $? -eq 0 ]; then
        log "CloudFormation stack deployed successfully"
    else
        error "Failed to deploy CloudFormation stack"
    fi
}

# Update kubeconfig
update_kubeconfig() {
    log "Updating kubeconfig..."
    
    aws eks update-kubeconfig \
        --name ${CLUSTER_NAME} \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "Kubeconfig updated successfully"
    else
        error "Failed to update kubeconfig"
    fi
}

# Deploy IAM roles
deploy_iam_roles() {
    log "Deploying IAM roles..."
    
    # Get OIDC provider ID
    OIDC_PROVIDER_ID=$(aws eks describe-cluster \
        --name ${CLUSTER_NAME} \
        --region ${REGION} \
        --query 'cluster.identity.oidc.issuer' \
        --output text | cut -d '/' -f 5)
    
    if [ -z "$OIDC_PROVIDER_ID" ]; then
        error "Failed to get OIDC provider ID"
    fi
    
    # Deploy IAM roles with OIDC provider ID
    aws cloudformation deploy \
        --template-file infrastructure/aws/iam-roles.yaml \
        --stack-name automind-${ENVIRONMENT}-iam-roles \
        --parameter-overrides Environment=${ENVIRONMENT} EKSClusterOIDCProviderId=${OIDC_PROVIDER_ID} \
        --capabilities CAPABILITY_IAM \
        --region ${REGION} \
        --no-fail-on-empty-changeset
    
    if [ $? -eq 0 ]; then
        log "IAM roles deployed successfully"
    else
        error "Failed to deploy IAM roles"
    fi
}

# Deploy Kubernetes manifests
deploy_kubernetes_manifests() {
    log "Deploying Kubernetes manifests..."
    
    # Create namespaces
    kubectl apply -f infrastructure/kubernetes/namespace.yaml
    
    # Deploy secrets and configmaps
    kubectl apply -f infrastructure/kubernetes/configmap.yaml
    kubectl apply -f infrastructure/kubernetes/secret.yaml
    
    # Deploy database and cache
    kubectl apply -f infrastructure/kubernetes/postgres.yaml
    kubectl apply -f infrastructure/kubernetes/redis.yaml
    
    # Wait for database to be ready
    log "Waiting for PostgreSQL to be ready..."
    kubectl wait --for=condition=ready pod -l app=automind,component=postgres -n automind --timeout=300s
    
    # Deploy applications
    kubectl apply -f infrastructure/kubernetes/service-account.yaml
    kubectl apply -f infrastructure/kubernetes/backend.yaml
    kubectl apply -f infrastructure/kubernetes/frontend.yaml
    
    # Wait for backend to be ready
    log "Waiting for backend to be ready..."
    kubectl wait --for=condition=available deployment/automind-backend -n automind --timeout=300s
    
    # Deploy monitoring and scaling
    kubectl apply -f infrastructure/kubernetes/hpa.yaml
    kubectl apply -f infrastructure/kubernetes/monitoring.yaml
    kubectl apply -f infrastructure/kubernetes/network-policy.yaml
    
    # Deploy ingress
    kubectl apply -f infrastructure/kubernetes/ingress.yaml
    
    if [ $? -eq 0 ]; then
        log "Kubernetes manifests deployed successfully"
    else
        error "Failed to deploy Kubernetes manifests"
    fi
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check pods
    log "Checking pod status..."
    kubectl get pods -n automind
    
    # Check services
    log "Checking service status..."
    kubectl get services -n automind
    
    # Check ingress
    log "Checking ingress status..."
    kubectl get ingress -n automind
    
    # Check HPA
    log "Checking HPA status..."
    kubectl get hpa -n automind
    
    log "Deployment verification completed"
}

# Get load balancer URL
get_load_balancer_url() {
    log "Getting Load Balancer URL..."
    
    # Get ALB DNS name from CloudFormation outputs
    ALB_DNS=$(aws cloudformation describe-stacks \
        --stack-name automind-${ENVIRONMENT}-infrastructure \
        --region ${REGION} \
        --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
        --output text)
    
    if [ -n "$ALB_DNS" ]; then
        log "Load Balancer URL: http://$ALB_DNS"
        log "You can access AutoMind at: http://$ALB_DNS"
    else
        warn "Could not retrieve Load Balancer URL"
    fi
}

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        error "Deployment failed. Check the logs above for details."
    fi
}

# Main deployment function
main() {
    log "Starting AutoMind EKS deployment for environment: ${ENVIRONMENT}"
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Run deployment steps
    check_prerequisites
    deploy_infrastructure
    update_kubeconfig
    deploy_iam_roles
    deploy_kubernetes_manifests
    verify_deployment
    get_load_balancer_url
    
    log "AutoMind EKS deployment completed successfully!"
    log "Next steps:"
    log "1. Update your DNS to point to the Load Balancer URL"
    log "2. Update the ingress host in infrastructure/kubernetes/ingress.yaml"
    log "3. Run 'kubectl logs -f deployment/automind-backend -n automind' to monitor"
    log "4. Access AutoMind at the Load Balancer URL shown above"
}

# Help function
show_help() {
    echo "AutoMind EKS Deployment Script"
    echo ""
    echo "Usage: $0 [ENVIRONMENT]"
    echo ""
    echo "Arguments:"
    echo "  ENVIRONMENT    Deployment environment (staging|production) [default: staging]"
    echo ""
    echo "Examples:"
    echo "  $0 staging"
    echo "  $0 production"
    echo ""
    echo "Prerequisites:"
    echo "  - AWS CLI configured"
    echo "  - kubectl installed"
    echo "  - Appropriate AWS permissions"
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
