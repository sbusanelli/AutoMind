#!/bin/bash

# AutoMind EKS Cleanup Script
# This script removes AutoMind from AWS EKS

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

# Update kubeconfig
update_kubeconfig() {
    log "Updating kubeconfig..."
    
    aws eks update-kubeconfig \
        --name ${CLUSTER_NAME} \
        --region ${REGION} \
        --alias automind-${ENVIRONMENT}
    
    if [ $? -eq 0 ]; then
        log "Kubeconfig updated successfully"
    else
        warn "Failed to update kubeconfig (cluster might not exist)"
    fi
}

# Remove Kubernetes manifests
remove_kubernetes_manifests() {
    log "Removing Kubernetes manifests..."
    
    # Remove in order of dependency
    kubectl delete -f infrastructure/kubernetes/ingress.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/monitoring.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/hpa.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/network-policy.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/frontend.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/backend.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/service-account.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/redis.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/postgres.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/secret.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/configmap.yaml --ignore-not-found=true
    kubectl delete -f infrastructure/kubernetes/namespace.yaml --ignore-not-found=true
    
    if [ $? -eq 0 ]; then
        log "Kubernetes manifests removed successfully"
    else
        warn "Some Kubernetes manifests might not exist"
    fi
}

# Remove CloudFormation stacks
remove_cloudformation_stacks() {
    log "Removing CloudFormation stacks..."
    
    # Remove IAM roles stack
    aws cloudformation delete-stack \
        --stack-name automind-${ENVIRONMENT}-iam-roles \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "IAM roles stack deletion initiated"
    else
        warn "IAM roles stack might not exist"
    fi
    
    # Wait for IAM roles stack to be deleted
    aws cloudformation wait stack-delete-complete \
        --stack-name automind-${ENVIRONMENT}-iam-roles \
        --region ${REGION} &
    
    # Remove infrastructure stack
    aws cloudformation delete-stack \
        --stack-name automind-${ENVIRONMENT}-infrastructure \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "Infrastructure stack deletion initiated"
    else
        warn "Infrastructure stack might not exist"
    fi
    
    # Wait for infrastructure stack to be deleted
    aws cloudformation wait stack-delete-complete \
        --stack-name automind-${ENVIRONMENT}-infrastructure \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "CloudFormation stacks deleted successfully"
    else
        warn "Some CloudFormation stacks might still be deleting"
    fi
}

# Remove EKS cluster
remove_eks_cluster() {
    log "Removing EKS cluster..."
    
    # Delete node group
    aws eks delete-nodegroup \
        --cluster-name ${CLUSTER_NAME} \
        --nodegroup-name automind-${ENVIRONMENT}-node-group \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "Node group deletion initiated"
    else
        warn "Node group might not exist"
    fi
    
    # Wait for node group to be deleted
    aws eks wait nodegroup-deleted \
        --cluster-name ${CLUSTER_NAME} \
        --nodegroup-name automind-${ENVIRONMENT}-node-group \
        --region ${REGION} &
    
    # Delete EKS cluster
    aws eks delete-cluster \
        --name ${CLUSTER_NAME} \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "EKS cluster deletion initiated"
    else
        warn "EKS cluster might not exist"
    fi
    
    # Wait for cluster to be deleted
    aws eks wait cluster-deleted \
        --name ${CLUSTER_NAME} \
        --region ${REGION}
    
    if [ $? -eq 0 ]; then
        log "EKS cluster deleted successfully"
    else
        warn "EKS cluster might still be deleting"
    fi
}

# Clean up Docker images (optional)
cleanup_docker_images() {
    log "Cleaning up Docker images..."
    
    # Remove local Docker images
    docker rmi sbusanelli/automind-backend:latest 2>/dev/null || true
    docker rmi sbusanelli/automind-frontend:latest 2>/dev/null || true
    
    log "Docker images cleaned up"
}

# Verify cleanup
verify_cleanup() {
    log "Verifying cleanup..."
    
    # Check if cluster still exists
    if aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} &>/dev/null; then
        warn "EKS cluster still exists"
    else
        log "EKS cluster removed successfully"
    fi
    
    # Check if CloudFormation stacks still exist
    if aws cloudformation describe-stack --stack-name automind-${ENVIRONMENT}-infrastructure --region ${REGION} &>/dev/null; then
        warn "Infrastructure CloudFormation stack still exists"
    else
        log "Infrastructure CloudFormation stack removed successfully"
    fi
    
    log "Cleanup verification completed"
}

# Main cleanup function
main() {
    log "Starting AutoMind EKS cleanup for environment: ${ENVIRONMENT}"
    
    # Run cleanup steps
    check_prerequisites
    update_kubeconfig
    remove_kubernetes_manifests
    remove_cloudformation_stacks
    remove_eks_cluster
    cleanup_docker_images
    verify_cleanup
    
    log "AutoMind EKS cleanup completed successfully!"
    log "Note: Some resources might still be deleting in the background"
    log "Check AWS Console for complete deletion status"
}

# Help function
show_help() {
    echo "AutoMind EKS Cleanup Script"
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
    echo "Warning: This will permanently remove all AutoMind resources!"
    echo "Make sure you have backups of any important data before running."
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        read -p "Are you sure you want to delete all AutoMind resources for environment '${ENVIRONMENT}'? This action cannot be undone. [y/N]: " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            main "$@"
        else
            echo "Cleanup cancelled."
            exit 0
        fi
        ;;
esac
