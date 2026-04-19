#!/bin/bash

# AutoMind Pre-commit Hook: Commit Message Validation
# Ensures commit messages follow conventional commits and security guidelines

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AutoMind Pre-commit Check: Commit Message Validation${NC}"

# Get the commit message
COMMIT_MSG_FILE="$1"
if [ -z "$COMMIT_MSG_FILE" ]; then
    COMMIT_MSG_FILE=".git/COMMIT_EDITMSG"
fi

if [ ! -f "$COMMIT_MSG_FILE" ]; then
    echo -e "${RED}ERROR: No commit message file found${NC}"
    exit 1
fi

COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Patterns that should not be in commit messages
FORBIDDEN_PATTERNS=(
    "password"
    "secret"
    "key"
    "token"
    "credential"
    "AKIA[0-9A-Z]{16}"
    "sk-[a-zA-Z0-9]{48}"
    "ghp_[a-zA-Z0-9]{36}"
    "-----BEGIN.*PRIVATE KEY-----"
    "-----BEGIN.*CERTIFICATE-----"
    "://.*@.*"
)

# Conventional commit types
ALLOWED_TYPES=(
    "feat"
    "fix"
    "docs"
    "style"
    "refactor"
    "perf"
    "test"
    "build"
    "ci"
    "chore"
    "revert"
    "security"
    "deps"
    "breaking"
)

ERRORS_FOUND=0

# Check if commit message is empty
if [ -z "$COMMIT_MSG" ]; then
    echo -e "${RED}ERROR: Commit message is empty${NC}"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
fi

# Check for forbidden patterns in commit message
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$COMMIT_MSG" | grep -qiE "$pattern"; then
        echo -e "${RED}ERROR: Commit message contains sensitive information: $pattern${NC}"
        echo -e "${RED}Remove sensitive information from commit message${NC}"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    fi
done

# Check if commit message follows conventional commits
if echo "$COMMIT_MSG" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|security|deps|breaking)(\(.+\))?: .{1,50}"; then
    echo -e "${GREEN}Commit message follows conventional commits format${NC}"
else
    echo -e "${YELLOW}WARNING: Commit message should follow conventional commits format${NC}"
    echo -e "${YELLOW}Format: type(scope): description${NC}"
    echo -e "${YELLOW}Types: ${ALLOWED_TYPES[*]}${NC}"
    echo -e "${YELLOW}Max length: 50 characters for subject line${NC}"
    
    # Don't fail for format issues, just warn
fi

# Check commit message length
SUBJECT=$(echo "$COMMIT_MSG" | head -n1)
SUBJECT_LENGTH=${#SUBJECT}

if [ $SUBJECT_LENGTH -gt 72 ]; then
    echo -e "${RED}ERROR: Commit message subject too long (${SUBJECT_LENGTH} characters)${NC}"
    echo -e "${RED}Subject should be max 72 characters${NC}"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
fi

if [ $SUBJECT_LENGTH -lt 10 ]; then
    echo -e "${RED}ERROR: Commit message subject too short (${SUBJECT_LENGTH} characters)${NC}"
    echo -e "${RED}Subject should be at least 10 characters${NC}"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
fi

# Check for proper capitalization
if [[ "$SUBJECT" =~ ^[a-z] ]]; then
    echo -e "${YELLOW}WARNING: Commit message subject should start with capital letter${NC}"
fi

# Check for period at end of subject
if [[ "$SUBJECT" =~ \.$ ]]; then
    echo -e "${YELLOW}WARNING: Commit message subject should not end with period${NC}"
fi

# Check for merge conflict markers
if echo "$COMMIT_MSG" | grep -qE "^<<<<<<< |^======= |^>>>>>>> "; then
    echo -e "${RED}ERROR: Commit message contains merge conflict markers${NC}"
    echo -e "${RED}Resolve merge conflicts before committing${NC}"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
fi

# Check for issue references
if echo "$COMMIT_MSG" | grep -qE "#[0-9]+"; then
    echo -e "${GREEN}Commit message references issue(s)${NC}"
else
    echo -e "${YELLOW}INFO: Consider referencing related issue numbers${NC}"
fi

# Check for breaking changes
if echo "$COMMIT_MSG" | grep -qiE "BREAKING CHANGE|breaking change|!: "; then
    echo -e "${YELLOW}WARNING: Breaking change detected${NC}"
    echo -e "${YELLOW}Ensure breaking changes are documented${NC}"
    echo -e "${YELLOW}Consider adding BREAKING CHANGE footer${NC}"
fi

# Check for security-related commits
if echo "$COMMIT_MSG" | grep -qiE "security|fix.*vulnerability|cve-|patch.*security"; then
    echo -e "${YELLOW}SECURITY: Security-related commit detected${NC}"
    echo -e "${YELLOW}Ensure security changes are properly reviewed${NC}"
    echo -e "${YELLOW}Consider updating security documentation${NC}"
fi

# Final status
if [ $ERRORS_FOUND -eq 0 ]; then
    echo -e "${GREEN}Commit message validation passed${NC}"
    echo -e "${GREEN}Safe to commit!${NC}"
    exit 0
else
    echo -e "${RED}Found $ERRORS_FOUND commit message issues${NC}"
    echo -e "${RED}Please fix these issues before committing${NC}"
    echo ""
    echo -e "${YELLOW}AutoMind Commit Guidelines:${NC}"
    echo -e "${YELLOW}1. Use conventional commits format${NC}"
    echo -e "${YELLOW}2. Keep subject under 72 characters${NC}"
    echo -e "${YELLOW}3. Start subject with capital letter${NC}"
    echo -e "${YELLOW}4. Don't end subject with period${NC}"
    echo -e "${YELLOW}5. Reference related issues when possible${NC}"
    echo -e "${YELLOW}6. Never include sensitive information${NC}"
    echo -e "${YELLOW}7. Document breaking changes clearly${NC}"
    echo ""
    echo -e "${YELLOW}Documentation: https://docs.automind.com/development/commits${NC}"
    exit 1
fi
