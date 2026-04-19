# AutoMind Pre-commit Hooks

Comprehensive pre-commit hook system to prevent accidental commits of sensitive files and ensure code quality and security.

## Overview

AutoMind pre-commit hooks provide multiple layers of security and quality checks before code is committed to version control. This prevents accidental exposure of secrets, ensures code quality, and maintains security standards.

## Features

### **Security Scanning**
- **Secret Detection**: Multiple tools to detect hardcoded secrets
- **File Validation**: Prevents sensitive file types from being committed
- **Permission Checks**: Ensures proper file permissions
- **Content Scanning**: Detects sensitive patterns in file content

### **Code Quality**
- **Linting**: TypeScript/JavaScript linting with security rules
- **Type Checking**: TypeScript compilation validation
- **Formatting**: Code formatting with Prettier
- **Security Auditing**: Dependency vulnerability scanning

### **Commit Standards**
- **Message Validation**: Conventional commits format enforcement
- **Issue References**: Ensures proper issue tracking
- **Breaking Changes**: Detection and documentation requirements

## Installation

### Quick Setup

```bash
# Run the setup script
./scripts/setup-pre-commit.sh

# Or install manually
pre-commit install
pre-commit install --hook-type commit-msg
pre-commit install --hook-type pre-push
```

### Manual Installation

1. **Install pre-commit**:
   ```bash
   pip install pre-commit
   # or
   npm install -g pre-commit
   ```

2. **Install security tools**:
   ```bash
   pip install detect-secrets
   go install github.com/zricethezav/gitleaks/v8/cmd/gitleaks@latest
   go install github.com/trufflesecurity/trufflehog/v3/cmd/trufflehog@latest
   ```

3. **Install hooks**:
   ```bash
   pre-commit install
   pre-commit install --hook-type commit-msg
   pre-commit install --hook-type pre-push
   ```

## Configuration

### Pre-commit Configuration (.pre-commit-config.yaml)

The main configuration file defines all hooks and their settings:

```yaml
# AutoMind Pre-commit Configuration
repos:
  # Security scanning
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        name: "Detect Hardcoded Secrets"
        args: ['--baseline', '.secrets.baseline']

  # Advanced secret detection
  - repo: https://github.com/zricethezav/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
        name: "Gitleaks Secret Detection"

  # Comprehensive secret scanning
  - repo: https://github.com/trufflesecurity/trufflehog
    rev: v3.68.0
    hooks:
      - id: trufflehog
        name: "TruffleHog Secret Scanning"

  # Code quality
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.56.0
    hooks:
      - id: eslint
        name: "ESLint Security Linting"

  # TypeScript checking
  - repo: https://github.com/digitalpulp/pre-commit-typescript
    rev: v5.0.0
    hooks:
      - id: tsc
        name: "TypeScript Type Checking"

  # Formatting
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.3
    hooks:
      - id: prettier
        name: "Prettier Formatting"

  # Security audits
  - repo: https://github.com/Lucas-C/pre-commit-hooks-node
    rev: v1.0.1
    hooks:
      - id: npm-audit
        name: "npm Audit Security Check"

  # Custom security checks
  - repo: local
    hooks:
      - id: check-hardcoded-env
        name: "Check Hardcoded Environment Variables"
        entry: scripts/check-hardcoded-env.sh

      - id: check-sensitive-files
        name: "Check Sensitive Files"
        entry: scripts/check-sensitive-files.sh

      - id: check-file-permissions
        name: "Check File Permissions"
        entry: scripts/check-file-permissions.sh

      - id: check-commit-message
        name: "Check Commit Message"
        entry: scripts/check-commit-message.sh
```

## Security Features

### **Secret Detection**

#### Multiple Tools for Comprehensive Coverage

1. **detect-secrets**: Basic secret pattern detection
2. **gitleaks**: Advanced secret scanning with custom rules
3. **trufflehog**: Deep scanning for embedded secrets

#### Supported Secret Types

- **AWS Credentials**: Access keys, secret keys
- **API Keys**: OpenAI, GitHub, Google, etc.
- **Database Credentials**: Connection strings, passwords
- **Certificates**: SSL/TLS certificates, private keys
- **Tokens**: JWT, OAuth, session tokens
- **SSH Keys**: Private keys, authorized keys

### **File Validation**

#### Blocked File Types

```bash
# Private keys and certificates
*.pem, *.key, *.p12, *.pfx, *.crt, *.jks, *.keystore

# Configuration files with secrets
credentials, *.secret, *.private, *.sensitive
secrets.yaml, secrets.yml, secrets.json

# Environment files
.env.local, .env.production, .env.staging
.env.development, .env.test, .env.dev, .env.prod

# Service account files
aws.pem, google.json, service-account.json
firebase.json, slack.json, github.json
openai.json, azure.json, gcp.json

# SSH and authentication files
.ssh/id_rsa, .ssh/id_ed25519, .ssh/authorized_keys
known_hosts, ssh_config, id_rsa.pub

# Database files
*.sql, *.db, *.sqlite, *.sqlite3
*.mdb, *.accdb, *.dbf, *.db3

# Large files (potential data dumps)
*.backup, *.bak, *.old, *.orig, *.save
```

### **Permission Validation**

#### Security Checks

- **World-writable files**: Blocked for security
- **Setuid/setgid bits**: Blocked in source code
- **Executable permissions**: Validated for appropriateness
- **Sensitive directories**: Restricted access validation

#### Recommended Permissions

```bash
# Regular files: 644 (rw-r--r--)
# Directories: 755 (rwxr-xr-x)
# Executable scripts: 755 (rwxr-xr-x)
# Sensitive files: 600 (rw-------)
```

### **Content Scanning**

#### Pattern Detection

```bash
# AWS Access Keys
AKIA[0-9A-Z]{16}

# OpenAI API Keys
sk-[a-zA-Z0-9]{48}

# GitHub Tokens
ghp_[a-zA-Z0-9]{36}

# Private Keys
-----BEGIN.*PRIVATE KEY-----

# Database URLs
://[^:]*:[^@]*@

# Hardcoded passwords
password\s*=\s*['\"][^'\"]{8,}['\"]
```

## Code Quality Features

### **Linting and Security**

#### ESLint Configuration

```javascript
{
  "extends": [
    "@typescript-eslint/recommended",
    "plugin:security/recommended"
  ],
  "rules": {
    "security/detect-object-injection": "error",
    "security/detect-non-literal-regexp": "error",
    "security/detect-unsafe-regex": "error",
    "security/detect-buffer-noassert": "error",
    "security/detect-child-process": "error",
    "security/detect-disable-mustache-escape": "error",
    "security/detect-eval-with-expression": "error",
    "security/detect-no-csrf-before-method-override": "error",
    "security/detect-non-literal-fs-filename": "error",
    "security/detect-non-literal-require": "error",
    "security/detect-possible-timing-attacks": "error",
    "security/detect-pseudoRandomBytes": "error"
  }
}
```

#### TypeScript Validation

- **Strict mode**: Enabled for type safety
- **No implicit any**: Prevents type errors
- **Null checks**: Prevents null/undefined errors
- **Unused variables**: Code cleanliness

### **Dependency Security**

#### npm Audit

- **High vulnerabilities**: Blocked from commit
- **Medium vulnerabilities**: Warning issued
- **Outdated packages**: Recommended updates

#### Supply Chain Security

- **Package integrity**: SHA-256 verification
- **License compliance**: License validation
- **Known vulnerabilities**: Database checks

## Commit Standards

### **Conventional Commits**

#### Format

```
type(scope): description

[optional body]

[optional footer]
```

#### Types

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code formatting
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Test additions/changes
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Maintenance tasks
- `revert`: Revert changes
- `security`: Security fixes
- `deps`: Dependency updates
- `breaking`: Breaking changes

#### Examples

```bash
feat(auth): add JWT token validation
fix(api): resolve database connection timeout
docs(readme): update installation instructions
security: patch XSS vulnerability in input validation
breaking(api): remove deprecated user endpoint
```

### **Message Validation**

#### Required Elements

- **Type**: Must be from allowed types list
- **Description**: Clear and concise (max 72 characters)
- **No secrets**: Never include sensitive information
- **Issue references**: When applicable

#### Blocked Content

- **Passwords**: Never in commit messages
- **API keys**: Never in commit messages
- **Tokens**: Never in commit messages
- **Credentials**: Never in commit messages

## Usage

### **Daily Development**

```bash
# Make changes
git add .

# Pre-commit hooks run automatically
git commit -m "feat(api): add user authentication"

# Hooks run again before push
git push origin main
```

### **Manual Hook Execution**

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run detect-secrets --all-files

# Run hooks on staged files only
pre-commit run

# Skip hooks (not recommended)
git commit --no-verify -m "message"
```

### **Baseline Management**

```bash
# Create new baseline
detect-secrets scan --baseline .secrets.baseline

# Update baseline
detect-secrets scan --baseline .secrets.baseline --update

# Gitleaks baseline
gitleaks protect --baseline-path .gitleaks-baseline.json
```

## Troubleshooting

### **Common Issues**

#### Hook Installation Failed

```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Clear cache
pre-commit clean
```

#### Secret Detection False Positives

```bash
# Add to baseline
detect-secrets scan --baseline .secrets.baseline

# Mark as false positive
echo "secret_pattern" >> .secrets.baseline
```

#### Permission Issues

```bash
# Fix script permissions
chmod +x scripts/*.sh

# Fix file permissions
chmod 644 filename
chmod 755 directory
```

#### Hook Timeout

```bash
# Increase timeout in .pre-commit-config.yaml
timeout: 300  # 5 minutes
```

### **Debug Mode**

```bash
# Run with verbose output
pre-commit run --verbose

# Run with debug output
pre-commit run --debug

# Run specific hook with debug
pre-commit run detect-secrets --verbose --debug
```

## Best Practices

### **Security**

1. **Never disable hooks**: Use `--no-verify` only in emergencies
2. **Review baselines**: Regularly review and update secret baselines
3. **Use vault integration**: Store secrets in vault, not code
4. **Environment variables**: Use env vars for configuration
5. **Regular audits**: Periodically review security scan results

### **Code Quality**

1. **Fix all linting errors**: Don't commit with linting issues
2. **Type safety**: Use TypeScript strict mode
3. **Test coverage**: Write tests for new features
4. **Documentation**: Update docs with code changes
5. **Dependencies**: Keep dependencies updated

### **Commit Standards**

1. **Conventional commits**: Follow the format strictly
2. **Clear descriptions**: Be specific about changes
3. **Issue references**: Link to related issues
4. **Breaking changes**: Document clearly
5. **Security fixes**: Use `security:` type

## Configuration Files

### **.pre-commit-config.yaml**

Main configuration file defining all hooks and their settings.

### **.secrets.baseline**

Baseline file for detect-secrets to ignore known false positives.

### **.gitleaks-baseline.json**

Baseline file for gitleaks to ignore known secrets.

### **.gitignore**

Updated to exclude sensitive files and tool outputs.

## Integration

### **CI/CD Integration**

#### GitHub Actions

```yaml
- name: Run security scans
  run: |
    pre-commit run --all-files
    trufflehog filesystem --directory . --fail
    gitleaks protect --verbose
```

#### GitLab CI

```yaml
security_scan:
  script:
    - pre-commit run --all-files
    - trufflehog filesystem --directory . --fail
    - gitleaks protect --verbose
```

### **IDE Integration**

#### VS Code

```json
{
  "git.enableSmartCommit": true,
  "git.autofetch": true,
  "git.postCommitCommand": "none",
  "git.allowNoVerifyCommit": false
}
```

#### JetBrains IDEs

- Enable pre-commit hooks in settings
- Configure automatic hook execution
- Set up commit message templates

## Monitoring and Reporting

### **Hook Performance**

```bash
# Check hook execution time
pre-commit run --timings

# Generate performance report
pre-commit run --all-files --timings > hook-performance.txt
```

### **Security Reports**

```bash
# Generate security scan report
trufflehog filesystem --directory . --json --output-file security-report.json

# Generate gitleaks report
gitleaks protect --report-format json --report-path gitleaks-report.json
```

### **Compliance**

- **SOC 2**: Security compliance documentation
- **GDPR**: Data protection compliance
- **ISO 27001**: Information security management
- **PCI DSS**: Payment card industry standards

## Support

### **Documentation**

- [AutoMind Security Guidelines](security-guidelines.md)
- [AutoMind Development Guide](development.md)
- [AutoMind API Documentation](api-reference.md)

### **Issues and Help**

- **GitHub Issues**: Report problems and request features
- **Security Issues**: Report security vulnerabilities privately
- **Documentation**: Contribute to documentation improvements

### **Community**

- **Discord**: Join the AutoMind community
- **Stack Overflow**: Tag questions with `automind`
- **Blog**: Follow security best practices

---

**Note**: Pre-commit hooks are a critical security measure. Never disable them unless absolutely necessary. Always review and understand why a hook is failing before bypassing it.

For more information, visit [AutoMind Documentation](https://docs.automind.com/security/pre-commit).
