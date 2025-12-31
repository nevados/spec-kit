---
description: Generate test file scaffolds from acceptance criteria
model: sonnet
---

Generate test scaffolds from extracted acceptance criteria.

## Input Required

- Story ID and title
- Acceptance criteria in G/W/T format
- Test framework (detected or specified)

## Framework Detection

Check for config files:

- `jest.config.*` → Jest
- `vitest.config.*` → Vitest
- `pytest.ini` / `pyproject.toml` → pytest
- `go.mod` → go test
- `phpunit.xml` → PHPUnit

## Output Format

Generate one test file per user story:

```typescript
// tests/[story-slug].test.ts
import { describe, it, expect } from '[framework]'

describe('[Story ID]: [Title]', () => {
  describe('[AC ID]: [Criterion summary]', () => {
    it('should [expected behavior]', async () => {
      // Given: [Precondition]
      // TODO: Setup test data

      // When: [Action]
      // TODO: Execute action

      // Then: [Expected outcome]
      // TODO: Assert results
      expect(true).toBe(false) // Placeholder - implement test
    })
  })
})
```

## Rules

- One test file per user story
- One describe block per acceptance criterion
- Include G/W/T as comments
- Use `expect(true).toBe(false)` placeholder to force implementation
- Follow project's existing test patterns if found
