---
name: test-scaffolding
description: Generates test scaffolds from acceptance criteria
allowed-tools: Read, Grep, Glob, Write
---

# Test Scaffolding Skill

Generate test file structures from specification acceptance criteria.

## Test Categories

### Unit Tests

- Pure function tests
- Class method tests
- Utility function tests
- Isolated component tests

### Integration Tests

- Service interaction tests
- Database operation tests
- API endpoint tests
- Middleware chain tests

### End-to-End Tests

- User flow tests
- Multi-step workflow tests
- Cross-service scenarios
- Full stack validation

## Generation Process

1. Extract acceptance criteria from spec
2. Identify testable behaviors
3. Detect project test framework
4. Generate scaffolds matching project patterns

## Framework Detection

- **JavaScript/TypeScript**: Jest, Vitest, Mocha
- **Python**: pytest, unittest
- **Go**: testing, testify
- **Rust**: built-in, tokio-test

## Output Structure

```text
tests/
  unit/
    [feature]-[component].test.[ext]
  integration/
    [feature]-[service].test.[ext]
  e2e/
    [feature]-[flow].test.[ext]
```

## Scaffold Pattern

```typescript
// [feature]-[component].test.ts
describe('[Feature] - [Component]', () => {
  describe('[Acceptance Criteria 1]', () => {
    it('should [expected behavior]', async () => {
      // Arrange
      // TODO: Set up test data
      // Act
      // TODO: Execute action
      // Assert
      // TODO: Verify outcome
    })
  })
})
```

## Rules

- One test file per component/service
- Group by acceptance criteria
- Include setup/teardown scaffolds
- Add TODO markers for implementation
- Match existing project patterns
