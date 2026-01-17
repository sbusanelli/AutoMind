#!/bin/bash

# Check for hardcoded environment variables in code
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Patterns that should not be hardcoded
PATTERNS=(
    "process\.env\."
    "process\.env\[.*\]"
    "\.env\."
    "AWS_ACCESS_KEY_ID\s*=\s*['\"]"
    "AWS_SECRET_ACCESS_KEY\s*=\s*['\"]"
    "GCP_SERVICE_ACCOUNT_KEY\s*=\s*['\"]"
    "AZURE_CLIENT_ID\s*=\s*['\"]"
    "AZURE_CLIENT_SECRET\s*=\s*['\"]"
    "GITHUB_TOKEN\s*=\s*['\"]"
    "OPENAI_API_KEY\s*=\s*['\"]"
    "SLACK_WEBHOOK_URL\s*=\s*['\"]"
    "AKIA[0-9A-Z]{16}"
    "sk-[a-zA-Z0-9]{48}"
    "ghp_[a-zA-Z0-9]{36}"
    "-----BEGIN.*PRIVATE KEY-----"
    "-----BEGIN.*CERTIFICATE-----"
    "-----BEGIN.*RSA PRIVATE KEY-----"
    "-----BEGIN.*OPENSSH PRIVATE KEY-----"
    "password\s*=\s*['\"]"
    "secret\s*=\s*['\"]"
    "token\s*=\s*['\"]"
    "key\s*=\s*['\"]"
    "api_key\s*=\s*['\"]"
    "api-key\s*=\s*['\"]"
    "apikey\s*=\s*['\"]"
)

echo -e "${YELLOW}🔍 Checking for hardcoded environment variables...${NC}"

ERRORS_FOUND=0

# Check each pattern in the staged files
for pattern in "${PATTERNS[@]}"; do
    if git diff --cached --name-only --diff-filter=AM | xargs grep -l "$pattern" 2>/dev/null; then
        echo -e "${RED}❌ Found hardcoded environment variable pattern: $pattern${NC}"
        echo -e "${RED}   Please use environment variables or vault integration instead${NC}"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
        
        # Show the offending lines
        git diff --cached --name-only --diff-filter=AM | xargs grep -n "$pattern" 2>/dev/null | while read -r line; do
            echo -e "${RED}   $line${NC}"
        done
    fi
done

# Check for direct credential assignments
DIRECT_PATTERNS=(
    "const.*=.*['\"][A-Z_]*KEY.*['\"]"
    "let.*=.*['\"][A-Z_]*KEY.*['\"]"
    "var.*=.*['\"][A-Z_]*KEY.*['\"]"
    "export.*[A-Z_]*KEY.*="
)

for pattern in "${DIRECT_PATTERNS[@]}"; do
    if git diff --cached --name-only --diff-filter=AM | xargs grep -l "$pattern" 2>/dev/null; then
        echo -e "${RED}❌ Found direct credential assignment: $pattern${NC}"
        echo -e "${RED}   Please use vault integration or environment variables${NC}"
        ERROR_S_FOUND=$((ERRORS_FOUND + 1))
    fi
done

# Check for base64 encoded secrets
if git diff --cached --name-only --diff-filter=AM | xargs grep -l "base64" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Found base64 encoding - please verify it's not a secret${NC}"
    git diff --cached --name-only --diff-filter=AM | xargs grep -n "base64" 2>/dev/null | while read -r line; do
        echo -e "${YELLOW}   $line${NC}"
    done
fi

# Check for URL patterns that might contain secrets
URL_PATTERNS=(
    "https://.*@.*"
    "http://.*@.*"
    "api\.openai\.com/v1/.*sk-"
    "hooks\.slack\.com/services/.*"
    "github\.com.*token.*ghp_"
    ".*\.amazonaws\.com.*AKIA"
)

for pattern in "${URL_PATTERNS[@]}"; do
    if git diff --cached --name-only --diff-filter=AM | xargs grep -l "$pattern" 2>/dev/null; then
        echo -e "${RED}❌ Found potential secret in URL: $pattern${NC}"
        echo -e "${RED}   Please use environment variables or vault integration${NC}"
        ERROR_S_FOUND=$((ERRORS_FOUND + 1))
    fi
done

if [ $ERRORS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No hardcoded environment variables found${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS_FOUND issues with hardcoded environment variables${NC}"
    echo -e "${RED}   Please fix before committing${NC}"
    echo -e "${YELLOW}💡 Use vault integration: https://docs.flowops.com/security/vault${NC}"
    exit 1
fi
