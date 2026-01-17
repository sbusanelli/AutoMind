#!/bin/bash

# Check for vault integration compliance
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔐 Checking vault integration compliance...${NC}"

ERRORS_FOUND=0

# Check for proper vault usage patterns
VAULT_PATTERNS=(
    "vault\.kv\.get"
    "vault\.read"
    "vault\.secret"
    "process\.env\.VAULT_"
    "VAULT_.*_ADDR"
    "VAULT_.*_TOKEN"
    "VAULT_.*_ROLE"
    "from.*vault"
    "import.*vault"
    "require.*vault"
)

# Check for anti-patterns (direct credential access)
ANTI_PATTERNS=(
    "process\.env\."
    "process\.env\[.*\]"
    "\.env\."
    "fs\.readFileSync.*\.env"
    "require.*\.env"
    "import.*\.env"
)

# Check staged files for vault compliance
for file in $(git diff --cached --name-only --diff-filter=AM | grep -E '\.(ts|tsx|js|jsx)$'); do
    echo "Checking $file..."
    
    # Check for vault usage
    VAULT_USAGE=0
    for pattern in "${VAULT_PATTERNS[@]}"; do
        if git show :$file | grep -q "$pattern" 2>/dev/null; then
            VAULT_USAGE=$((VAULT_USAGE + 1))
        fi
    done
    
    # Check for anti-patterns
    ANTI_PATTERN_COUNT=0
    for pattern in "${ANTI_PATTERNS[@]}"; do
        if git show :$file | grep -q "$pattern" 2>/dev/null; then
            ANTI_PATTERN_COUNT=$((ANTI_PATTERN_COUNT + 1))
        fi
    done
    
    # Evaluate compliance
    if [ $ANTI_PATTERN_COUNT -gt 0 ] && [ $VAULT_USAGE -eq 0 ]; then
        echo -e "${RED}❌ $file: Found direct credential access without vault integration${NC}"
        echo -e "${RED}   Please use vault integration for credential management${NC}"
        ERROR_S_FOUND=$((ERRORS_FOUND + 1))
    elif [ $VAULT_USAGE -gt 0 ]; then
        echo -e "${GREEN}✅ $file: Properly using vault integration${NC}"
    else
        echo -e "${YELLOW}ℹ️  $file: No credential access detected${NC}"
    fi
done

# Check for vault configuration files
if git diff --cached --name-only --diff-filter=AM | grep -q "vault\.config\|vault\.json\|\.vaultrc" 2>/dev/null; then
    echo -e "${GREEN}✅ Vault configuration files detected${NC}"
fi

# Check for proper environment variable usage
ENV_PATTERNS=(
    "process\.env\.VAULT_"
    "process\.env\.CREDENTIALS_"
    "process\.env\.SECRETS_"
)

for file in $(git diff --cached --name-only --diff-filter=AM | grep -E '\.(ts|tsx|js|jsx)$'); do
    ENV_USAGE=0
    for pattern in "${ENV_PATTERNS[@]}"; do
        if git show :$file | grep -q "$pattern" 2>/dev/null; then
            ENV_USAGE=$((ENV_USAGE + 1))
        fi
    done
    
    if [ $ENV_USAGE -gt 0 ]; then
        echo -e "${GREEN}✅ $file: Properly using environment variables${NC}"
    fi
done

# Check for credential service usage
if git diff --cached --name-only --diff-filter=AM | xargs grep -l "credentialService\|CredentialService" 2>/dev/null; then
    echo -e "${GREEN}✅ Credential service integration detected${NC}"
fi

# Check for hardcoded secrets in configuration files
CONFIG_FILES=$(git diff --cached --name-only --diff-filter=AM | grep -E '\.(json|yaml|yml|config|conf)$' || true)

for file in $CONFIG_FILES; do
    # Check for secret patterns in config files
    if git show :$file | grep -q -E "(password|secret|key|token).*=.*['\"]" 2>/dev/null; then
        echo -e "${RED}❌ $file: Found hardcoded secret in configuration${NC}"
        echo -e "${RED}   Please use vault integration or environment variables${NC}"
        ERROR_S_FOUND=$((ERRORS_FOUND + 1))
    fi
done

if [ $ERRORS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ Vault integration compliance check passed${NC}"
    echo -e "${GREEN}   No hardcoded credentials detected${NC}"
    echo -e "${GREEN}   Proper vault usage patterns found${NC}"
    exit 0
else
    echo -e "${RED}❌ Vault integration compliance check failed${NC}"
    echo -e "${RED}   Found $ERRORS_FOUND compliance issues${NC}"
    echo -e "${YELLOW}💡 Please review vault integration guidelines:${NC}"
    echo -e "${YELLOW}   - Use process.env.VAULT_* for vault variables${NC}"
    echo -e "${YELLOW}   - Import credentialService for credential management${NC}"
    echo -e "${YELLOW}   - Never hardcode secrets in configuration files${NC}"
    echo -e "${YELLOW}   - Use vault KV store for secret management${NC}"
    exit 1
fi
