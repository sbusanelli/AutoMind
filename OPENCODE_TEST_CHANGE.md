# OpenCode Integration Test

This file is created to test the OpenCode AI code review integration.

## Purpose

- Test OpenCode workflow trigger
- Verify AI code review functionality
- Validate comment-based activation (`/oc` command)
- Check integration with GitHub Actions

## Test Scenarios

1. **Basic Review**: `/oc` command should trigger quick review
2. **Detailed Review**: `/opencode` command should trigger comprehensive review
3. **Custom Prompt**: `/opencode security` should trigger security-focused review

## Expected Results

- OpenCode workflow should trigger automatically
- AI should analyze the code changes
- Review comments should be posted on the PR
- Workflow artifacts should contain logs

## Code Quality Check

This is a simple markdown file, but OpenCode should still provide feedback on:
- Documentation quality
- Formatting standards
- Content completeness

---

*This file will be removed after testing is complete.*
