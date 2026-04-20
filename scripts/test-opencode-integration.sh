#!/bin/bash

# OpenCode Integration Test Script
# This script tests the OpenCode AI code review functionality

set -e

echo "=== OpenCode Integration Test ==="
echo "Testing AI code review functionality..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test functions
test_basic_review() {
    echo -e "${YELLOW}Testing basic code review...${NC}"
    
    # Create a simple test change
    cat > test-basic-review.ts << 'EOF'
// Basic test for OpenCode review
function testFunction() {
    console.log("This is a test function");
    var x = 1 + 2; // Using var instead of let/const
    return x;
}
EOF

    git add test-basic-review.ts
    git commit -m "test: Add basic code review test file

This commit tests OpenCode AI code review functionality with:
- Basic function definition
- Code quality issue (var instead of let/const)
- Simple logic for AI analysis

/oc"  # This should trigger OpenCode

    echo "Basic review test committed with /oc command"
}

test_security_review() {
    echo -e "${YELLOW}Testing security-focused review...${NC}"
    
    # Create a security test file
    cat > test-security-review.ts << 'EOF'
// Security test for OpenCode review
import crypto from 'crypto';

function insecureFunction(userInput: string) {
    // Security issues for AI to detect
    const sql = "SELECT * FROM users WHERE name = '" + userInput + "'"; // SQL injection
    eval("console.log('User input: ' + userInput)"); // Eval usage
    
    // Hardcoded secret
    const secret = "super-secret-key";
    
    return sql;
}
EOF

    git add test-security-review.ts
    git commit -m "test: Add security-focused code review test

This commit tests OpenCode AI security analysis with:
- SQL injection vulnerability
- eval() usage (critical security issue)
- Hardcoded secrets
- Input validation issues

/opencode security"  # This should trigger OpenCode with security focus

    echo "Security review test committed with /opencode security command"
}

test_performance_review() {
    echo -e "${YELLOW}Testing performance-focused review...${NC}"
    
    # Create a performance test file
    cat > test-performance-review.ts << 'EOF'
// Performance test for OpenCode review
function processDataSlow(data: any[]) {
    // Performance issues for AI to detect
    let result = [];
    for (let i = 0; i < data.length; i++) { // Inefficient loop
        for (let j = 0; j < data[i].items.length; j++) { // Nested loop O(n²)
            result.push(data[i].items[j]);
        }
    }
    return result;
}

function memoryLeak() {
    // Potential memory leak
    const largeArray = new Array(1000000).fill(0);
    setInterval(() => {
        largeArray.push(Math.random()); // Array grows indefinitely
    }, 1000);
}
EOF

    git add test-performance-review.ts
    git commit -m "test: Add performance-focused code review test

This commit tests OpenCode AI performance analysis with:
- Inefficient nested loops (O(n²) complexity)
- Potential memory leak
- Large array operations
- Performance bottlenecks

/opencode performance"  # This should trigger OpenCode with performance focus

    echo "Performance review test committed with /opencode performance command"
}

test_comprehensive_review() {
    echo -e "${YELLOW}Testing comprehensive code review...${NC}"
    
    # Create a comprehensive test file
    cat > test-comprehensive-review.ts << 'EOF'
// Comprehensive test for OpenCode review
import express from 'express';

class ComplexClass {
    private data: any[] = [];
    
    constructor() {
        this.initializeData();
    }
    
    // Long method (maintainability issue)
    private initializeData() {
        for (let i = 0; i < 1000; i++) {
            this.data.push({
                id: i,
                name: "item_" + i,
                value: Math.random() * 100,
                description: "This is a very long description that makes the line exceed 120 characters which is a maintainability issue that should be detected by the AI code reviewer",
                metadata: {
                    created: new Date(),
                    updated: new Date(),
                    version: "1.0.0",
                    tags: ["test", "data", "sample", "item", "comprehensive", "review", "test"]
                }
            });
        }
    }
    
    // Complex method with multiple issues
    public processData(input: any): any {
        var result = {}; // Using var
        
        // No error handling
        result.processed = input.map((item: any) => {
            return item.value * 2; // No null check for item.value
        });
        
        // Potential null reference
        result.count = result.processed.length;
        
        return result;
    }
}

export default ComplexClass;
EOF

    git add test-comprehensive-review.ts
    git commit -m "test: Add comprehensive code review test

This commit tests OpenCode AI comprehensive analysis with:
- Class-based architecture
- Long methods (maintainability)
- Mixed code quality issues
- Type safety concerns
- Performance considerations
- Security best practices

/opencode"  # This should trigger comprehensive OpenCode review

    echo "Comprehensive review test committed with /opencode command"
}

# Main execution
main() {
    echo "Starting OpenCode integration tests..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository${NC}"
        exit 1
    fi
    
    # Check current branch
    current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    
    # Run tests
    test_basic_review
    sleep 2
    
    test_security_review
    sleep 2
    
    test_performance_review
    sleep 2
    
    test_comprehensive_review
    
    echo -e "${GREEN}=== OpenCode Integration Tests Completed ===${NC}"
    echo "Check GitHub Actions for OpenCode workflow results"
    echo "Expected triggers:"
    echo "1. Basic review (/oc command)"
    echo "2. Security review (/opencode security)"
    echo "3. Performance review (/opencode performance)"
    echo "4. Comprehensive review (/opencode)"
    echo ""
    echo "Monitor the GitHub Actions tab for workflow execution and AI review results"
}

# Run main function
main "$@"
