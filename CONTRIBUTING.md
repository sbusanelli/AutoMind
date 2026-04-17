# Contributing to AutoMind

Thank you for your interest in contributing to AutoMind! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Node.js 20+ 
- Docker and Docker Compose
- Git
- A GitHub account

### Development Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/AutoMind.git
   cd AutoMind
   ```

2. **Install dependencies**
   ```bash
   # Backend dependencies
   cd backend
   npm install
   
   # Frontend dependencies
   cd ../frontend
   npm install
   ```

3. **Set up development environment**
   ```bash
   # Start development services
   cd infrastructure/docker
   docker-compose -f docker-compose.dev.yml up -d
   
   # Start backend in development mode
   cd ../../backend
   npm run dev
   
   # Start frontend in development mode (new terminal)
   cd ../frontend
   npm start
   ```

## 🏗️ Project Structure

```
AutoMind/
├── backend/                 # Node.js/Express API
│   ├── src/                # Source code
│   ├── tests/              # Backend tests
│   └── package.json
├── frontend/               # React frontend
│   ├── src/               # Source code
│   ├── public/            # Static assets
│   └── package.json
├── infrastructure/         # Infrastructure as code
│   ├── docker/           # Docker configurations
│   ├── kubernetes/       # K8s manifests
│   └── aws/             # CloudFormation templates
├── docs/                 # Documentation
├── scripts/              # Utility scripts
└── .github/             # GitHub workflows and templates
```

## 📝 How to Contribute

### Reporting Bugs

- Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) template
- Provide clear steps to reproduce
- Include environment details (OS, Node.js version, etc.)
- Add relevant logs or screenshots

### Suggesting Features

- Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) template
- Describe the problem you're trying to solve
- Explain why this feature would be valuable
- Consider implementation complexity

### Code Contributions

1. **Create an issue** (if one doesn't exist) describing your planned changes
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following our coding standards
4. **Test thoroughly**:
   ```bash
   # Run backend tests
   cd backend && npm test
   
   # Run frontend tests
   cd frontend && npm test
   
   # Run integration tests
   npm run test:integration
   ```
5. **Commit your changes** with clear messages:
   ```bash
   git commit -m "feat: add user authentication system"
   ```
6. **Push to your fork** and create a pull request

### Coding Standards

- **TypeScript**: Use TypeScript for type safety
- **ESLint**: Follow ESLint configuration
- **Prettier**: Use Prettier for code formatting
- **Conventional Commits**: Use conventional commit messages
- **Tests**: Write tests for new features
- **Documentation**: Update docs for API changes

#### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Examples:
```
feat(auth): add JWT token refresh
fix(api): handle null response from user service
docs(readme): update installation instructions
```

## 🧪 Testing

### Running Tests

```bash
# All tests
npm test

# Backend tests only
cd backend && npm test

# Frontend tests only
cd frontend && npm test

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e

# Coverage report
npm run test:coverage
```

### Test Requirements

- Unit tests for all new functions
- Integration tests for API endpoints
- E2E tests for user workflows
- Minimum 80% code coverage

## 📚 Documentation

- Update README.md for user-facing changes
- Add inline code comments for complex logic
- Update API documentation for endpoint changes
- Document new configuration options

## 🔍 Code Review Process

1. **Automated checks** must pass:
   - All tests
   - Code coverage
   - Security scans
   - Linting

2. **Manual review** focuses on:
   - Code quality and architecture
   - Performance implications
   - Security considerations
   - Documentation completeness

3. **Approval requirements**:
   - At least one maintainer approval
   - All automated checks passed
   - No merge conflicts

## 🏷️ Release Process

1. **Version bump** following semantic versioning
2. **Changelog** update with all changes
3. **Release notes** generation
4. **Tag creation** and GitHub release
5. **Deployment** to staging/production

## 💬 Getting Help

- **Discord**: [Join our community](https://discord.gg/automind)
- **Discussions**: [GitHub Discussions](https://github.com/sbusanelli/AutoMind/discussions)
- **Issues**: [Create an issue](https://github.com/sbusanelli/AutoMind/issues)
- **Email**: [your-email@example.com]

## 📄 License

By contributing to AutoMind, you agree that your contributions will be licensed under the same license as the project.

## 🙏 Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- Annual contributor highlights
- Special contributor badges

Thank you for contributing to AutoMind! 🎉
