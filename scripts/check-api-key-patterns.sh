#!/bin/bash

# Check for API key patterns and potential secrets
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔑 Checking for API key patterns and potential secrets...${NC}"

ERRORS_FOUND=0

# AWS API Key patterns
AWS_PATTERNS=(
    "AKIA[0-9A-Z]{16}"
    "aws_access_key_id\s*=\s*['\"]?[A-Z0-9]{16}['\"]?"
    "aws_secret_access_key\s*=\s*['\"]?[a-zA-Z0-9+/]{40}['\"]?"
    "AWS_.*_KEY\s*=\s*['\"]?[A-Za-z0-9+/=]{20,}['\"]?"
)

# GCP Service Account patterns
GCP_PATTERNS=(
    "\"type\":\s*\"service_account\""
    "\"project_id\":\s*\"[a-z0-9-]+\""
    "\"private_key_id\":\s*\"[a-z0-9-]+\""
    "\"private_key\":\s*\"-----BEGIN.*PRIVATE KEY-----"
    "service-account.*@.*\.iam\.gserviceaccount\.com"
    "gcp.*service.*account.*key"
)

# Azure patterns
AZURE_PATTERNS=(
    "client_id\s*=\s*['\"]?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}['\"]?"
    "client_secret\s*=\s*['\"]?[a-zA-Z0-9+/=]{20,}['\"]?"
    "tenant_id\s*=\s*['\"]?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}['\"]?"
    "subscription_id\s*=\s*['\"]?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}['\"]?"
)

# GitHub patterns
GITHUB_PATTERNS=(
    "ghp_[a-zA-Z0-9]{36}"
    "gho_[a-zA-Z0-9]{36}"
    "ghu_[a-zA-Z0-9]{36}"
    "ghs_[a-zA-Z0-9]{36}"
    "ghr_[a-zA-Z0-9]{36}"
    "github_token\s*=\s*['\"]?ghp_[a-zA-Z0-9]{36}['\"]?"
    "GITHUB_TOKEN\s*=\s*['\"]?ghp_[a-zA-Z0-9]{36}['\"]?"
)

# OpenAI patterns
OPENAI_PATTERNS=(
    "sk-[a-zA-Z0-9]{48}"
    "org-[a-zA-Z0-9]{24}"
    "openai_api_key\s*=\s*['\"]?sk-[a-zA-Z0-9]{48}['\"]?"
    "OPENAI_API_KEY\s*=\s*['\"]?sk-[a-zA-Z0-9]{48}['\"]?"
)

# Generic API key patterns
GENERIC_PATTERNS=(
    "api_key\s*=\s*['\"]?[a-zA-Z0-9_-]{20,}['\"]?"
    "api-key\s*=\s*['\"]?[a-zA-Z0-9_-]{20,}['\"]?"
    "apikey\s*=\s*['\"]?[a-zA-Z0-9_-]{20,}['\"]?"
    "token\s*=\s*['\"]?[a-zA-Z0-9_-]{20,}['\"]?"
    "secret\s*=\s*['\"]?[a-zA-Z0-9_-]{20,}['\"]?"
    "password\s*=\s*['\"]?[a-zA-Z0-9_-]{8,}['\"]?"
)

# Database connection patterns
DB_PATTERNS=(
    "mongodb://.*:.*@.*"
    "mysql://.*:.*@.*"
    "postgresql://.*:.*@.*"
    "redis://.*:.*@.*"
    "connection.*string.*password"
    "database.*url.*password"
)

# JWT patterns
JWT_PATTERNS=(
    "eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*"
    "jwt.*token.*eyJ"
    "JWT_TOKEN\s*=\s*['\"]?eyJ.*['\"]?"
)

# SSL Certificate patterns
SSL_PATTERNS=(
    "-----BEGIN.*PRIVATE KEY-----"
    "-----BEGIN.*CERTIFICATE-----"
    "-----BEGIN.*RSA PRIVATE KEY-----"
    "-----BEGIN.*OPENSSH PRIVATE KEY-----"
    "-----END.*PRIVATE KEY-----"
    "-----END.*CERTIFICATE-----"
    "-----END.*RSA PRIVATE KEY-----"
    "-----END.*OPENSSH PRIVATE KEY-----"
)

# Function to check patterns in a file
check_patterns_in_file() {
    local file=$1
    local pattern_name=$2
    shift 2
    local patterns=("$@")
    
    for pattern in "${patterns[@]}"; do
        if git show :$file | grep -q "$pattern" 2>/dev/null; then
            echo -e "${RED}❌ $file: Found $pattern_name pattern: $pattern${NC}"
            echo -e "${RED}   This should be loaded from vault or environment variables${NC}"
            return 1
        fi
    done
    return 0
}

# Check all staged files
for file in $(git diff --cached --name-only --diff-filter=AM | grep -E '\.(ts|tsx|js|jsx|json|yaml|yml|env|config|conf)$'); do
    echo "Checking $file for API key patterns..."
    
    # Skip certain files
    case $file in
        *.env.credentials|*.secrets|*.key|*.pem|*.crt)
            echo -e "${YELLOW}⚠️  Skipping $file (credential file)${NC}"
            continue
            ;;
        test/*|spec/*)
            echo -e "${YELLOW}⚠️  Skipping $file (test file)${NC}"
            continue
            ;;
    esac
    
    FILE_ERRORS=0
    
    # Check each pattern category
    if check_patterns_in_file "$file" "AWS API Key" "${AWS_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "GCP Service Account" "${GCP_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "Azure" "${AZURE_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "GitHub" "${GITHUB_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "OpenAI" "${OPENAI_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "Generic API Key" "${GENERIC_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "Database Connection" "${DB_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "JWT Token" "${JWT_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if check_patterns_in_file "$file" "SSL Certificate" "${SSL_PATTERNS[@]}"; then
        FILE_ERRORS=$((FILE_ERRORS + 1))
    fi
    
    if [ $FILE_ERRORS -eq 0 ]; then
        echo -e "${GREEN}✅ $file: No API key patterns detected${NC}"
    fi
    
    ERROR_S_FOUND=$((ERROR_S_FOUND + FILE_ERRORS))
done

# Check for base64 encoded secrets
echo "Checking for base64 encoded secrets..."
for file in $(git diff --cached --name-only --diff-filter=AM | grep -E '\.(ts|tsx|js|jsx|json)$'); do
    if git show :$file | grep -q "base64" 2>/dev/null; then
        # Check if it looks like a base64 encoded secret
        BASE64_CONTENT=$(git show :$file | grep -o "base64[^'\"]*" | head -1)
        if [ -n "$BASE64_CONTENT" ]; then
            # Try to decode and check if it looks like a secret
            DECODED=$(echo "$BASE64_CONTENT" | base64 -d 2>/dev/null || echo "")
            if [ -n "$DECODED" ]; then
                if echo "$DECODED" | grep -q -E "(key|secret|token|password)"; then
                    echo -e "${RED}❌ $file: Found potential base64 encoded secret${NC}"
                    ERROR_S_FOUND=$((ERROR_S_FOUND + 1))
                fi
            fi
        fi
    fi
done

if [ $ERROR_S_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ API key pattern check passed${NC}"
    echo -e "${GREEN}   No hardcoded API keys or secrets found${NC}"
    echo -e "${GREEN}   All secrets should be loaded from vault or environment${NC}"
    exit 0
else
    echo -e "${RED}❌ API key pattern check failed${NC}"
    echo -e "${RED}   Found $ERROR_S_FOUND potential secrets${NC}"
    echo -e "${YELLOW}💡 Security recommendations:${NC}"
    echo -e "${YELLOW}   - Use HashiCorp Vault for secret management${NC}"
    echo -e "${YELLOW}   - Load secrets from environment variables${NC}"
    echo -e "${YELLOW}   - Never commit secrets to version control${NC}"
    echo -e "${YELLOW}   - Use credential rotation automation${NC}"
    exit 1
fi
