#!/bin/bash

# AutoMind Pre-commit Hook: Check for Sensitive Files
# Prevents accidental commits of sensitive files

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Files and patterns that should never be committed
SENSITIVE_PATTERNS=(
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx"
    "*.crt"
    "*.jks"
    "*.keystore"
    "*.p8"
    "*.p7b"
    "*.p7c"
    "*.p7m"
    "*.p7s"
    "*.asc"
    "*.gpg"
    "*.pgp"
    "*.ssh"
    "id_rsa"
    "id_ed25519"
    "id_ecdsa"
    "*.pem.backup"
    "*.key.backup"
    "credentials"
    ".env.local"
    ".env.production"
    ".env.staging"
    ".env.development"
    ".env.test"
    ".env.dev"
    ".env.prod"
    "config/secrets.yml"
    "config/database.yml"
    "config/application.yml"
    "*.secret"
    "*.private"
    "*.sensitive"
    "secrets.yaml"
    "secrets.yml"
    "secrets.json"
    "private_key.pem"
    "public_key.pem"
    "aws.pem"
    "google.json"
    "service-account.json"
    "firebase.json"
    "slack.json"
    "github.json"
    "openai.json"
    "azure.json"
    "gcp.json"
    "kubeseal.json"
    "vault-token"
    ".aws/credentials"
    ".aws/config"
    ".docker/config.json"
    ".npmrc"
    ".pgpass"
    ".my.cnf"
    ".netrc"
    "_netrc"
    ".bash_history"
    ".zsh_history"
    ".history"
    ".lesshstg"
    ".mysql_history"
    ".psql_history"
    ".rediscli_history"
    ".mongorc.js"
    ".mongosh.js"
    ".mongorc.yml"
    ".mongorc.yaml"
    ".mongorc.json"
    "mongorc.js"
    "mongorc.yml"
    "mongorc.yaml"
    "mongorc.json"
    ".kube/config"
    "kubeconfig"
    "kubectl-config"
    "kubectl.yaml"
    "kubectl.yml"
    "kubectl.json"
    ".kubectl/config"
    "kubectl-config"
    "kubectl.yaml"
    "kubectl.yml"
    "kubectl.json"
    ".ssh/id_rsa"
    ".ssh/id_ed25519"
    ".ssh/id_ecdsa"
    ".ssh/id_dsa"
    ".ssh/known_hosts"
    ".ssh/authorized_keys"
    ".ssh/config"
    "ssh_host_rsa_key"
    "ssh_host_ed25519_key"
    "ssh_host_ecdsa_key"
    "ssh_host_dsa_key"
    "authorized_keys"
    "known_hosts"
    "ssh_config"
    "id_rsa.pub"
    "id_ed25519.pub"
    "id_ecdsa.pub"
    "id_dsa.pub"
    "ssh_host_rsa_key.pub"
    "ssh_host_ed25519_key.pub"
    "ssh_host_ecdsa_key.pub"
    "ssh_host_dsa_key.pub"
    "*.backup"
    "*.bak"
    "*.old"
    "*.orig"
    "*.save"
    "*.tmp"
    "*.temp"
    "*.swp"
    "*.swo"
    "*.swn"
    "*.un~"
    ".DS_Store"
    "Thumbs.db"
    "desktop.ini"
    "*.log"
    "*.out"
    "*.err"
    "*.trace"
    "*.debug"
    "*.dump"
    "*.sql"
    "*.db"
    "*.sqlite"
    "*.sqlite3"
    "*.mdb"
    "*.accdb"
    "*.dbf"
    "*.db3"
    "*.s3db"
    "*.sl3"
    "*.db-journal"
    "*.db-shm"
    "*.db-wal"
    "*.ldb"
    "*.ldf"
    "*.mdf"
    "*.ndf"
    "*.sdf"
    "*.ibd"
    "*.myd"
    "*.myi"
    "*.frm"
    "*.aria"
    "*.TRN"
    "*.TRG"
    "*.opt"
    "*.par"
    "*.csm"
    "*.csv"
    "*.tsv"
    "*.psv"
    "*.dat"
    "*.data"
    "*.bin"
    "*.hex"
    "*.raw"
    "*.img"
    "*.iso"
    "*.dmg"
    "*.vhd"
    "*.vmdk"
    "*.ova"
    "*.ovf"
    "*.qcow2"
    "*.vdi"
    "*.qed"
    "*.raw"
    "*.img"
    "*.backup"
    "*.bak"
    "*.old"
    "*.orig"
    "*.save"
    "*.tmp"
    "*.temp"
    "*.swp"
    "*.swo"
    "*.swn"
    "*.un~"
    ".#*"
    "#*#"
    "*~"
    "*.swp"
    "*.tmp"
    "*.bak"
    "*.orig"
    "*.rej"
    "*.patch"
    "*.diff"
    "*.patch~"
    "*.diff~"
    "*.rej~"
    "*.orig~"
    "*.bak~"
    "*.tmp~"
    "*.swp~"
    "*.swo~"
    "*.swn~"
    "*.un~~"
    ".#*~"
    "#*#~"
    "*~~"
    "*.swp"
    "*.tmp"
    "*.bak"
    "*.orig"
    "*.rej"
    "*.patch"
    "*.diff"
    "*.patch~"
    "*.diff~"
    "*.rej~"
    "*.orig~"
    "*.bak~"
    "*.tmp~"
    "*.swp~"
    "*.swo~"
    "*.swn~"
    "*.un~~"
    ".#*~"
    "#*#~"
    "*~~"
)

echo -e "${BLUE}AutoMind Pre-commit Check: Sensitive Files${NC}"
echo -e "${YELLOW}Scanning for sensitive files that should not be committed...${NC}"

ERRORS_FOUND=0
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No staged files to check${NC}"
    exit 0
fi

# Check each staged file against sensitive patterns
for file in $STAGED_FILES; do
    # Skip if file doesn't exist (deleted file)
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # Check file name against sensitive patterns
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if [[ "$file" == $pattern ]]; then
            echo -e "${RED}ERROR: Sensitive file detected: $file${NC}"
            echo -e "${RED}This file type should never be committed to version control${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
            break
        fi
    done
    
    # Check file content for sensitive patterns
    if [ -f "$file" ]; then
        # Check for private key content
        if grep -q "-----BEGIN.*PRIVATE KEY-----" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: Private key content found in: $file${NC}"
            echo -e "${RED}Remove private keys from version control${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for certificate content
        if grep -q "-----BEGIN.*CERTIFICATE-----" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: Certificate content found in: $file${NC}"
            echo -e "${RED}Certificates should be managed separately${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for AWS credentials
        if grep -q "AKIA[0-9A-Z]{16}" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: AWS access key found in: $file${NC}"
            echo -e "${RED}Use environment variables or AWS IAM roles${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for OpenAI API keys
        if grep -q "sk-[a-zA-Z0-9]{48}" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: OpenAI API key found in: $file${NC}"
            echo -e "${RED}Use environment variables or vault integration${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for GitHub tokens
        if grep -q "ghp_[a-zA-Z0-9]{36}" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: GitHub token found in: $file${NC}"
            echo -e "${RED}Use environment variables or GitHub Apps${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for passwords in configuration files
        if grep -q "password\s*=\s*['\"][^'\"]{8,}['\"]" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: Hardcoded password found in: $file${NC}"
            echo -e "${RED}Use environment variables or vault integration${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for database connection strings with credentials
        if grep -q "://[^:]*:[^@]*@" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR: Database connection string with credentials found in: $file${NC}"
            echo -e "${RED}Use environment variables or vault integration${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # Check for large files (potential data dumps)
        file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        if [ "$file_size" -gt 10485760 ]; then  # 10MB
            echo -e "${YELLOW}WARNING: Large file detected: $file (${file_size} bytes)${NC}"
            echo -e "${YELLOW}Consider if this file should be in version control${NC}"
        fi
    fi
done

# Check for .gitignore violations
if [ -f ".gitignore" ]; then
    echo -e "${BLUE}Checking .gitignore violations...${NC}"
    
    for file in $STAGED_FILES; do
        if [ -f "$file" ]; then
            # Check if file matches any .gitignore pattern
            if git check-ignore "$file" >/dev/null 2>&1; then
                echo -e "${RED}ERROR: File $file is ignored by .gitignore but being committed${NC}"
                echo -e "${RED}Remove it from the commit or update .gitignore${NC}"
                ERRORS_FOUND=$((ERRORS_FOUND + 1))
            fi
        fi
    done
fi

# Final status
if [ $ERRORS_FOUND -eq 0 ]; then
    echo -e "${GREEN}No sensitive files detected${NC}"
    echo -e "${GREEN}Safe to commit!${NC}"
    exit 0
else
    echo -e "${RED}Found $ERRORS_FOUND sensitive file issues${NC}"
    echo -e "${RED}Please fix these issues before committing${NC}"
    echo ""
    echo -e "${YELLOW}AutoMind Security Guidelines:${NC}"
    echo -e "${YELLOW}1. Use environment variables for configuration${NC}"
    echo -e "${YELLOW}2. Store secrets in vault or secret manager${NC}"
    echo -e "${YELLOW}3. Never commit credentials, keys, or certificates${NC}"
    echo -e "${YELLOW}4. Use .gitignore to exclude sensitive files${NC}"
    echo -e "${YELLOW}5. Review all changes before committing${NC}"
    echo ""
    echo -e "${YELLOW}Documentation: https://docs.automind.com/security/guidelines${NC}"
    exit 1
fi
