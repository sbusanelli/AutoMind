#!/bin/bash

# AutoMind Pre-commit Hooks Setup Script
# Installs and configures pre-commit hooks for security and quality

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AutoMind Pre-commit Hooks Setup${NC}"
echo -e "${YELLOW}Installing security and quality pre-commit hooks...${NC}"

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo -e "${RED}ERROR: pre-commit is not installed${NC}"
    echo -e "${YELLOW}Installing pre-commit...${NC}"
    
    # Try to install pre-commit
    if command -v pip &> /dev/null; then
        pip install pre-commit
    elif command -v pip3 &> /dev/null; then
        pip3 install pre-commit
    elif command -v npm &> /dev/null; then
        npm install -g pre-commit
    else
        echo -e "${RED}ERROR: Cannot install pre-commit automatically${NC}"
        echo -e "${YELLOW}Please install pre-commit manually:${NC}"
        echo -e "${YELLOW}  pip install pre-commit${NC}"
        echo -e "${YELLOW}  or npm install -g pre-commit${NC}"
        exit 1
    fi
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}ERROR: git is not installed${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Not in a git repository${NC}"
    echo -e "${YELLOW}Run this script from the root of a git repository${NC}"
    exit 1
fi

# Create scripts directory if it doesn't exist
mkdir -p scripts

# Make scripts executable
echo -e "${YELLOW}Making scripts executable...${NC}"
chmod +x scripts/*.sh

# Install pre-commit hooks
echo -e "${YELLOW}Installing pre-commit hooks...${NC}"
pre-commit install

# Install pre-commit commit-msg hook
echo -e "${YELLOW}Installing commit message hook...${NC}"
pre-commit install --hook-type commit-msg

# Install pre-commit pre-push hook
echo -e "${YELLOW}Installing pre-push hook...${NC}"
pre-commit install --hook-type pre-push

# Create baseline files for secret detection
echo -e "${YELLOW}Creating baseline files for secret detection...${NC}"

# Create detect-secrets baseline
if [ ! -f ".secrets.baseline" ]; then
    echo -e "${BLUE}Creating detect-secrets baseline...${NC}"
    detect-secrets scan --baseline .secrets.baseline
fi

# Create gitleaks baseline
if [ ! -f ".gitleaks-baseline.json" ]; then
    echo -e "${BLUE}Creating gitleaks baseline...${NC}"
    gitleaks protect --baseline-path .gitleaks-baseline.json --verbose --redact
fi

# Install additional security tools
echo -e "${YELLOW}Installing additional security tools...${NC}"

# Install trufflehog if not available
if ! command -v trufflehog &> /dev/null; then
    echo -e "${YELLOW}Installing trufflehog...${NC}"
    if command -v go &> /dev/null; then
        go install github.com/trufflesecurity/trufflehog/v3/cmd/trufflehog@latest
    else
        echo -e "${YELLOW}Go not found, skipping trufflehog installation${NC}"
        echo -e "${YELLOW}Install manually: go install github.com/trufflesecurity/trufflehog/v3/cmd/trufflehog@latest${NC}"
    fi
fi

# Install gitleaks if not available
if ! command -v gitleaks &> /dev/null; then
    echo -e "${YELLOW}Installing gitleaks...${NC}"
    if command -v go &> /dev/null; then
        go install github.com/zricethezav/gitleaks/v8/cmd/gitleaks@latest
    else
        echo -e "${YELLOW}Go not found, skipping gitleaks installation${NC}"
        echo -e "${YELLOW}Install manually: go install github.com/zricethezav/gitleaks/v8/cmd/gitleaks@latest${NC}"
    fi
fi

# Install detect-secrets if not available
if ! command -v detect-secrets &> /dev/null; then
    echo -e "${YELLOW}Installing detect-secrets...${NC}"
    if command -v pip &> /dev/null; then
        pip install detect-secrets
    elif command -v pip3 &> /dev/null; then
        pip3 install detect-secrets
    else
        echo -e "${YELLOW}pip not found, skipping detect-secrets installation${NC}"
        echo -e "${YELLOW}Install manually: pip install detect-secrets${NC}"
    fi
fi

# Install hadolint for Docker security
if ! command -v hadolint &> /dev/null; then
    echo -e "${YELLOW}Installing hadolint...${NC}"
    if command -v brew &> /dev/null; then
        brew install hadolint
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y hadolint
    else
        echo -e "${YELLOW}Package manager not found, skipping hadolint installation${NC}"
        echo -e "${YELLOW}Install manually: https://github.com/hadolint/hadolint#installation${NC}"
    fi
fi

# Install yamllint for YAML security
if ! command -v yamllint &> /dev/null; then
    echo -e "${YELLOW}Installing yamllint...${NC}"
    if command -v pip &> /dev/null; then
        pip install yamllint
    elif command -v pip3 &> /dev/null; then
        pip3 install yamllint
    elif command -v npm &> /dev/null; then
        npm install -g yamllint
    else
        echo -e "${YELLOW}Package manager not found, skipping yamllint installation${NC}"
        echo -e "${YELLOW}Install manually: pip install yamllint${NC}"
    fi
fi

# Create custom pre-commit hooks directory
mkdir -p .git/hooks

# Create custom pre-commit hook
echo -e "${YELLOW}Creating custom pre-commit hook...${NC}"
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# AutoMind Custom Pre-commit Hook
# Runs additional checks before commit

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AutoMind Custom Pre-commit Checks${NC}"

# Run sensitive files check
if [ -f "scripts/check-sensitive-files.sh" ]; then
    scripts/check-sensitive-files.sh
fi

# Run file permissions check
if [ -f "scripts/check-file-permissions.sh" ]; then
    scripts/check-file-permissions.sh
fi

# Run pre-commit hooks
if command -v pre-commit &> /dev/null; then
    pre-commit run --all-files
fi

echo -e "${GREEN}All pre-commit checks passed!${NC}"
EOF

chmod +x .git/hooks/pre-commit

# Create custom commit-msg hook
echo -e "${YELLOW}Creating custom commit-msg hook...${NC}"
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

# AutoMind Custom Commit Message Hook
# Validates commit messages

set -e

if [ -f "scripts/check-commit-message.sh" ]; then
    scripts/check-commit-message.sh "$1"
fi
EOF

chmod +x .git/hooks/commit-msg

# Create custom pre-push hook
echo -e "${YELLOW}Creating custom pre-push hook...${NC}"
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# AutoMind Custom Pre-push Hook
# Runs additional checks before push

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AutoMind Pre-push Checks${NC}"

# Run security scan before push
echo -e "${YELLOW}Running security scan before push...${NC}"

# Check for any new secrets
if command -v trufflehog &> /dev/null; then
    echo -e "${BLUE}Scanning for secrets with trufflehog...${NC}"
    if ! trufflehog filesystem --directory . --fail --no-update; then
        echo -e "${RED}ERROR: Secrets found in repository${NC}"
        echo -e "${RED}Remove secrets before pushing${NC}"
        exit 1
    fi
fi

# Run gitleaks scan
if command -v gitleaks &> /dev/null; then
    echo -e "${BLUE}Scanning for secrets with gitleaks...${NC}"
    if ! gitleaks protect --verbose --redact; then
        echo -e "${RED}ERROR: Secrets found in repository${NC}"
        echo -e "${RED}Remove secrets before pushing${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}All pre-push checks passed!${NC}"
EOF

chmod +x .git/hooks/pre-push

# Update .gitignore to exclude sensitive files
echo -e "${YELLOW}Updating .gitignore...${NC}"
cat >> .gitignore << 'EOF'

# AutoMind Security - Sensitive files
*.pem
*.key
*.p12
*.pfx
*.crt
*.jks
*.keystore
*.p8
*.p7b
*.p7c
*.p7m
*.p7s
*.asc
*.gpg
*.pgp
*.ssh
id_rsa
id_ed25519
id_ecdsa
*.pem.backup
*.key.backup
credentials
.env.local
.env.production
.env.staging
.env.development
.env.test
.env.dev
.env.prod
config/secrets.yml
config/database.yml
config/application.yml
*.secret
*.private
*.sensitive
secrets.yaml
secrets.yml
secrets.json
private_key.pem
public_key.pem
aws.pem
google.json
service-account.json
firebase.json
slack.json
github.json
openai.json
azure.json
gcp.json
kubeseal.json
vault-token
.aws/credentials
.aws/config
.docker/config.json
.npmrc
.pgpass
.my.cnf
.netrc
_netrc
.bash_history
.zsh_history
.history
.lesshstg
.mysql_history
.psql_history
.rediscli_history
.mongorc.js
.mongosh.js
.mongorc.yml
.mongorc.yaml
.mongorc.json
.kube/config
kubeconfig
kubectl-config
kubectl.yaml
kubectl.yml
kubectl.json
.ssh/id_rsa
.ssh/id_ed25519
.ssh/id_ecdsa
.ssh/id_dsa
.ssh/known_hosts
.ssh/authorized_keys
.ssh/config
ssh_host_rsa_key
ssh_host_ed25519_key
ssh_host_ecdsa_key
ssh_host_dsa_key
authorized_keys
known_hosts
ssh_config
id_rsa.pub
id_ed25519.pub
id_ecdsa.pub
id_dsa.pub
ssh_host_rsa_key.pub
ssh_host_ed25519_key.pub
ssh_host_ecdsa_key.pub
ssh_host_dsa_key.pub

# AutoMind Security - Baseline files
.secrets.baseline
.gitleaks-baseline.json
trufflehog-results.json

# AutoMind Security - Tool outputs
*.security-scan
*.secret-scan
*.audit-report
*.vulnerability-report
*.security-report
EOF

# Test pre-commit installation
echo -e "${YELLOW}Testing pre-commit installation...${NC}"
if pre-commit run --all-files --verbose; then
    echo -e "${GREEN}Pre-commit hooks installed successfully!${NC}"
else
    echo -e "${YELLOW}Some pre-commit hooks failed, but installation completed${NC}"
    echo -e "${YELLOW}Fix any issues before committing${NC}"
fi

# Display summary
echo ""
echo -e "${GREEN}AutoMind Pre-commit Setup Complete!${NC}"
echo ""
echo -e "${BLUE}Installed Hooks:${NC}"
echo -e "${YELLOW}  - Pre-commit: Code quality and security checks${NC}"
echo -e "${YELLOW}  - Commit-msg: Commit message validation${NC}"
echo -e "${YELLOW}  - Pre-push: Security scans before push${NC}"
echo ""
echo -e "${BLUE}Security Tools:${NC}"
echo -e "${YELLOW}  - detect-secrets: Hardcoded secret detection${NC}"
echo -e "${YELLOW}  - gitleaks: Advanced secret scanning${NC}"
echo -e "${YELLOW}  - trufflehog: Comprehensive secret detection${NC}"
echo -e "${YELLOW}  - hadolint: Docker security linting${NC}"
echo -e "${YELLOW}  - yamllint: YAML security linting${NC}"
echo ""
echo -e "${BLUE}Custom Checks:${NC}"
echo -e "${YELLOW}  - Sensitive files detection${NC}"
echo -e "${YELLOW}  - File permissions validation${NC}"
echo -e "${YELLOW}  - Hardcoded environment variables${NC}"
echo -e "${YELLOW}  - API key pattern detection${NC}"
echo -e "${YELLOW}  - Vault compliance checking${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "${YELLOW}1. Review and update .pre-commit-config.yaml${NC}"
echo -e "${YELLOW}2. Test hooks by making a commit${NC}"
echo -e "${YELLOW}3. Update baselines when legitimate secrets are added${NC}"
echo -e "${YELLOW}4. Configure CI/CD to run similar checks${NC}"
echo ""
echo -e "${GREEN}Your repository is now protected against accidental secret commits!${NC}"
echo -e "${GREEN}Documentation: https://docs.automind.com/security/pre-commit${NC}"
