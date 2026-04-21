#!/bin/bash

# AutoMind Pre-commit Hook: File Permissions Check
# Ensures files have appropriate permissions for security

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AutoMind Pre-commit Check: File Permissions${NC}"
echo -e "${YELLOW}Scanning for insecure file permissions...${NC}"

ERRORS_FOUND=0
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No staged files to check${NC}"
    exit 0
fi

# Check each staged file
for file in $STAGED_FILES; do
    # Skip if file doesn't exist (deleted file)
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # Get file permissions in octal format
    if command -v stat >/dev/null 2>&1; then
        # macOS/BSD stat
        if stat -f "%A" "$file" >/dev/null 2>&1; then
            PERMS=$(stat -f "%A" "$file")
        else
            # GNU stat
            PERMS=$(stat -c "%a" "$file")
        fi
    else
        echo -e "${YELLOW}WARNING: stat command not available, skipping permission check${NC}"
        continue
    fi
    
    # Check for world-writable files
    if [ "$PERMS" -ge 002 ]; then
        echo -e "${RED}ERROR: File is world-writable: $file (permissions: $PERMS)${NC}"
        echo -e "${RED}Remove world-write permission: chmod o-w $file${NC}"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    fi
    
    # Check for world-readable files that might contain sensitive data
    if [ "$PERMS" -ge 004 ]; then
        # Check if file might contain sensitive data based on name
        if [[ "$file" =~ (config|secret|key|password|credential|token|private) ]]; then
            echo -e "${YELLOW}WARNING: Potentially sensitive file is world-readable: $file (permissions: $PERMS)${NC}"
            echo -e "${YELLOW}Consider restricting access: chmod o-r $file${NC}"
        fi
    fi
    
    # Check for executable files that shouldn't be
    if [ "$PERMS" -ge 011 ]; then
        # Check file extension to determine if it should be executable
        case "$file" in
            *.sh|*.py|*.rb|*.pl|*.php|*.js|*.ts|*.jsx|*.tsx)
                # Script files - executable is okay
                ;;
            Dockerfile*|*.dockerfile)
                # Docker files - executable is okay
                ;;
            Makefile|makefile|*.mk)
                # Make files - executable is okay
                ;;
            *)
                # Other files - check if executable is appropriate
                if file "$file" 2>/dev/null | grep -q "executable"; then
                    echo -e "${GREEN}INFO: Executable file detected: $file${NC}"
                else
                    echo -e "${YELLOW}WARNING: Non-script file has execute permission: $file (permissions: $PERMS)${NC}"
                    echo -e "${YELLOW}Consider removing execute permission: chmod -x $file${NC}"
                fi
                ;;
        esac
    fi
    
    # Check for setuid/setgid bits
    if [ "$PERMS" -ge 4000 ] || [ "$PERMS" -ge 2000 ]; then
        echo -e "${RED}ERROR: File has setuid/setgid bits: $file (permissions: $PERMS)${NC}"
        echo -e "${RED}Remove setuid/setgid bits: chmod ug-s $file${NC}"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    fi
    
    # Check for sticky bit (usually not needed in source code)
    if [ "$PERMS" -ge 1000 ]; then
        echo -e "${YELLOW}WARNING: File has sticky bit: $file (permissions: $PERMS)${NC}"
        echo -e "${YELLOW}Remove sticky bit: chmod -t $file${NC}"
    fi
done

# Check directory permissions for sensitive directories
SENSITIVE_DIRS=(
    "config"
    "secrets"
    "keys"
    "credentials"
    "tokens"
    "private"
    ".ssh"
    ".aws"
    ".kube"
)

for dir in "${SENSITIVE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        if stat -f "%A" "$dir" >/dev/null 2>&1; then
            # macOS/BSD stat
            DIR_PERMS=$(stat -f "%A" "$dir")
        else
            # GNU stat
            DIR_PERMS=$(stat -c "%a" "$dir")
        fi
        
        if [ "$DIR_PERMS" -ge 007 ]; then
            echo -e "${RED}ERROR: Sensitive directory is world-accessible: $dir (permissions: $DIR_PERMS)${NC}"
            echo -e "${RED}Restrict directory access: chmod o-rwx $dir${NC}"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
    fi
done

# Check for files with unusual permissions
UNUSUAL_PERMS=(
    "000"  # No permissions at all
    "001"  # Only execute
    "002"  # Only write
    "003"  # Write and execute
    "777"  # All permissions
)

for file in $STAGED_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    if stat -f "%A" "$file" >/dev/null 2>&1; then
        # macOS/BSD stat
        PERMS=$(stat -f "%A" "$file")
    else
        # GNU stat
        PERMS=$(stat -c "%a" "$file")
    fi
    
    for unusual in "${UNUSUAL_PERMS[@]}"; do
        if [ "$PERMS" = "$unusual" ]; then
            echo -e "${YELLOW}WARNING: File has unusual permissions: $file (permissions: $PERMS)${NC}"
            echo -e "${YELLOW}Review if these permissions are appropriate${NC}"
            break
        fi
    done
done

# Final status
if [ $ERRORS_FOUND -eq 0 ]; then
    echo -e "${GREEN}No permission issues found${NC}"
    echo -e "${GREEN}Safe to commit!${NC}"
    exit 0
else
    echo -e "${RED}Found $ERRORS_FOUND permission issues${NC}"
    echo -e "${RED}Please fix these issues before committing${NC}"
    echo ""
    echo -e "${YELLOW}AutoMind Security Guidelines:${NC}"
    echo -e "${YELLOW}1. Remove world-write permissions from all files${NC}"
    echo -e "${YELLOW}2. Restrict access to sensitive files and directories${NC}"
    echo -e "${YELLOW}3. Use execute permissions only for scripts${NC}"
    echo -e "${YELLOW}4. Avoid setuid/setgid bits in source code${NC}"
    echo -e "${YELLOW}5. Use 644 for regular files, 755 for directories${NC}"
    echo ""
    echo -e "${YELLOW}Documentation: https://docs.automind.com/security/permissions${NC}"
    exit 1
fi
