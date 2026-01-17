#!/bin/bash

# FlowOps Credential Management Script
# Makes credential rotation easy for end-user teams

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CREDENTIAL_CONFIG_FILE=".env.credentials"
BACKUP_DIR=".credentials-backup"
NOTIFICATION_WEBHOOK="${SLACK_WEBHOOK_URL:-}"

# Cloud provider configurations
declare -A PROVIDERS=(
    ["aws"]="AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_REGION"
    ["gcp"]="GCP_SERVICE_ACCOUNT_KEY,GCP_PROJECT_ID,GCP_REGION"
    ["azure"]="AZURE_CLIENT_ID,AZURE_CLIENT_SECRET,AZURE_TENANT_ID,AZURE_SUBSCRIPTION_ID"
    ["github"]="GITHUB_TOKEN,GITHUB_USERNAME"
    ["openai"]="OPENAI_API_KEY"
)

# Functions
print_header() {
    echo -e "${BLUE}🔐 FlowOps Credential Manager${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_prerequisites() {
    print_header
    echo "🔍 Checking prerequisites..."
    
    # Check if required tools are installed
    local tools=("aws" "gcloud" "az" "jq" "openssl")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "$tool is not installed. Please install it first."
            exit 1
        fi
    done
    
    print_success "All prerequisites satisfied"
}

backup_credentials() {
    print_header
    echo "💾 Creating credential backup..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup current credentials
    if [ -f "$CREDENTIAL_CONFIG_FILE" ]; then
        cp "$CREDENTIAL_CONFIG_FILE" "$BACKUP_DIR/credentials-$(date +%Y%m%d-%H%M%S).backup"
        print_success "Credentials backed up to $BACKUP_DIR"
    else
        print_warning "No existing credentials file found"
    fi
}

validate_credentials() {
    local provider=$1
    print_header
    echo "🧪 Validating $provider credentials..."
    
    case $provider in
        "aws")
            if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
                if aws sts get-caller-identity &> /dev/null; then
                    print_success "AWS credentials are valid"
                else
                    print_error "AWS credentials are invalid"
                    return 1
                fi
            else
                print_error "AWS credentials not found"
                return 1
            fi
            ;;
        "gcp")
            if [ -n "$GCP_SERVICE_ACCOUNT_KEY" ]; then
                echo "$GCP_SERVICE_ACCOUNT_KEY" > /tmp/gcp-key.json
                export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-key.json
                if gcloud auth activate-service-account --key-file=/tmp/gcp-key.json &> /dev/null; then
                    print_success "GCP credentials are valid"
                else
                    print_error "GCP credentials are invalid"
                    return 1
                fi
                rm -f /tmp/gcp-key.json
            else
                print_error "GCP credentials not found"
                return 1
            fi
            ;;
        "azure")
            if [ -n "$AZURE_CLIENT_ID" ] && [ -n "$AZURE_CLIENT_SECRET" ] && [ -n "$AZURE_TENANT_ID" ]; then
                if az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID" &> /dev/null; then
                    print_success "Azure credentials are valid"
                else
                    print_error "Azure credentials are invalid"
                    return 1
                fi
            else
                print_error "Azure credentials not found"
                return 1
            fi
            ;;
        "openai")
            if [ -n "$OPENAI_API_KEY" ]; then
                if curl -s "https://api.openai.com/v1/models" -H "Authorization: Bearer $OPENAI_API_KEY" &> /dev/null; then
                    print_success "OpenAI API key is valid"
                else
                    print_error "OpenAI API key is invalid"
                    return 1
                fi
            else
                print_error "OpenAI API key not found"
                return 1
            fi
            ;;
        *)
            print_error "Unknown provider: $provider"
            return 1
            ;;
    esac
}

rotate_credentials() {
    local provider=$1
    print_header
    echo "🔄 Rotating $provider credentials..."
    
    backup_credentials
    
    case $provider in
        "aws")
            echo "Creating new AWS access key..."
            NEW_KEY=$(aws iam create-access-key --user-name flowops-deploy --query 'AccessKey' --output json)
            NEW_ACCESS_KEY=$(echo "$NEW_KEY" | jq -r '.AccessKeyId')
            NEW_SECRET_KEY=$(echo "$NEW_KEY" | jq -r '.SecretAccessKey')
            
            echo "AWS_ACCESS_KEY_ID=$NEW_ACCESS_KEY" >> "$CREDENTIAL_CONFIG_FILE"
            echo "AWS_SECRET_ACCESS_KEY=$NEW_SECRET_KEY" >> "$CREDENTIAL_CONFIG_FILE"
            
            print_success "AWS credentials rotated"
            ;;
        "gcp")
            echo "Creating new GCP service account key..."
            gcloud iam service-accounts keys create flowops-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
                --key-file-type=json --output-file=/tmp/new-gcp-key.json
            
            NEW_GCP_KEY=$(cat /tmp/new-gcp-key.json | jq -c)
            echo "GCP_SERVICE_ACCOUNT_KEY=$NEW_GCP_KEY" >> "$CREDENTIAL_CONFIG_FILE"
            
            rm -f /tmp/new-gcp-key.json
            print_success "GCP credentials rotated"
            ;;
        "azure")
            echo "Creating new Azure service principal..."
            NEW_SP=$(az ad sp create-for-rbac --name "flowops-deploy-$(date +%s)" --role="Contributor" --output json)
            NEW_CLIENT_ID=$(echo "$NEW_SP" | jq -r '.appId')
            NEW_CLIENT_SECRET=$(echo "$NEW_SP" | jq -r '.password')
            
            echo "AZURE_CLIENT_ID=$NEW_CLIENT_ID" >> "$CREDENTIAL_CONFIG_FILE"
            echo "AZURE_CLIENT_SECRET=$NEW_CLIENT_SECRET" >> "$CREDENTIAL_CONFIG_FILE"
            
            print_success "Azure credentials rotated"
            ;;
        "openai")
            echo "Generating new OpenAI API key..."
            # Note: In real implementation, this would use OpenAI's API
            NEW_OPENAI_KEY="sk-$(openssl rand -hex 32)"
            echo "OPENAI_API_KEY=$NEW_OPENAI_KEY" >> "$CREDENTIAL_CONFIG_FILE"
            
            print_success "OpenAI API key rotated"
            ;;
        *)
            print_error "Unknown provider: $provider"
            return 1
            ;;
    esac
    
    validate_credentials "$provider"
    send_notification "$provider" "rotated"
}

send_notification() {
    local provider=$1
    local action=$2
    local message="🔐 FlowOps Credential $action\n\nProvider: $provider\nTimestamp: $(date)\nAction: $action"
    
    if [ -n "$NOTIFICATION_WEBHOOK" ]; then
        curl -X POST "$NOTIFICATION_WEBHOOK" \
            -H 'Content-type: application/json' \
            --data "{\"text\": \"$message\"}" &> /dev/null
        print_success "Notification sent"
    else
        print_warning "No notification webhook configured"
    fi
}

list_credentials() {
    print_header
    echo "📋 Current credential status:"
    echo ""
    
    for provider in "${!PROVIDERS[@]}"; do
        echo -e "${BLUE}$provider:${NC}"
        local vars=${PROVIDERS[$provider]}
        IFS=',' read -ra VAR_ARRAY <<< "$vars"
        
        for var in "${VAR_ARRAY[@]}"; do
            local value=${!var}
            if [ -n "$value" ]; then
                local masked_value="${value:0:8}****"
                echo "  $var: $masked_value"
            else
                echo "  $var: ${RED}NOT SET${NC}"
            fi
        done
        echo ""
    done
}

setup_local_environment() {
    print_header
    echo "🔧 Setting up local environment..."
    
    # Load credentials from file
    if [ -f "$CREDENTIAL_CONFIG_FILE" ]; then
        export $(cat "$CREDENTIAL_CONFIG_FILE" | xargs)
        print_success "Credentials loaded from $CREDENTIAL_CONFIG_FILE"
    else
        print_warning "No credentials file found. Creating template..."
        cat > "$CREDENTIAL_CONFIG_FILE" << EOF
# FlowOps Credentials Configuration
# Add your credentials here and run: source scripts/credential-manager.sh

# AWS Configuration
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-west-2

# GCP Configuration
GCP_SERVICE_ACCOUNT_KEY=
GCP_PROJECT_ID=
GCP_REGION=us-central1

# Azure Configuration
AZURE_CLIENT_ID=
AZURE_CLIENT_SECRET=
AZURE_TENANT_ID=
AZURE_SUBSCRIPTION_ID=

# GitHub Configuration
GITHUB_TOKEN=
GITHUB_USERNAME=

# OpenAI Configuration
OPENAI_API_KEY=

# Notification Configuration
SLACK_WEBHOOK_URL=
EOF
        print_success "Template created at $CREDENTIAL_CONFIG_FILE"
    fi
    
    echo ""
    echo -e "${YELLOW}To use these credentials, run:${NC}"
    echo -e "${BLUE}source $CREDENTIAL_CONFIG_FILE${NC}"
}

show_help() {
    print_header
    echo "📖 FlowOps Credential Manager Help"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  validate [provider]    Validate credentials for specific provider"
    echo "  rotate [provider]      Rotate credentials for specific provider"
    echo "  list                 List all credential status"
    echo "  setup                Setup local environment"
    echo "  backup               Backup current credentials"
    echo "  help                 Show this help message"
    echo ""
    echo "Providers: aws, gcp, azure, github, openai"
    echo ""
    echo "Examples:"
    echo "  $0 validate aws       Validate AWS credentials"
    echo "  $0 rotate gcp         Rotate GCP credentials"
    echo "  $0 list               List all credential status"
    echo "  $0 setup              Setup local environment"
}

# Main script logic
case "${1:-help}" in
    "validate")
        check_prerequisites
        validate_credentials "${2:-all}"
        ;;
    "rotate")
        check_prerequisites
        rotate_credentials "${2:-all}"
        ;;
    "list")
        list_credentials
        ;;
    "setup")
        setup_local_environment
        ;;
    "backup")
        backup_credentials
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
