---
description: Generate test scaffolds from spec acceptance criteria
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## Input

```text
$ARGUMENTS
```

## Goal

Generate test file scaffolds from acceptance criteria in spec.md, enabling TDD
workflow where specs become directly executable through tests.

## Execution

**Session init**: `mkdir -p .specify && touch .specify/.active-session`

1. **Initialize**: Run `{SCRIPT}` for FEATURE_DIR, FEATURE_SPEC

2. **Extract acceptance criteria** (Task agent with haiku):

   **Criteria Extraction Agent**:
   - Task: "Extract all acceptance criteria from spec.md. Parse or convert to
     Given/When/Then format. Classify as unit/integration/e2e."
   - Input: spec.md
   - Output: Structured list with story ID, criterion ID, G/W/T, test type
   - Token: <2K

3. **Detect test framework** (from plan.md or codebase):
   - Check plan.md for testing stack
   - If not specified, scan for: jest.config, vitest.config, pytest.ini,
     phpunit.xml, etc.
   - Default by language: JS→Vitest, Python→pytest, Go→go test

4. **Generate test scaffolds** (Task agent with sonnet):

   For each acceptance criterion:

   **Test Scaffold Agent**:
   - Task: "Generate test scaffold for criterion. Include file path, function
     name, test body with TODO markers, Arrange/Act/Assert structure."
   - Input: Story ID, criterion text, detected framework
   - Output: Complete test file scaffold per story
   - Token: <4K per story

5. **Write test files**:
   - Group by user story → one test file per story
   - Path: `tests/` or `__tests__/` or `spec/` (detect convention)
   - Filename: `{story-slug}.test.{ext}`

   Example output:

   ```typescript
   // tests/us1-user-registration.test.ts
   import { describe, it, expect } from 'vitest'

   describe('US1: User Registration', () => {
     describe('AC1: Valid email registration', () => {
       it('should register user with valid email', async () => {
         // Given: A new user with valid email
         // TODO: Setup test user data

         // When: User submits registration
         // TODO: Call registration endpoint/function

         // Then: User account is created
         // TODO: Assert user exists in database
         expect(true).toBe(false) // Placeholder - implement test
       })
     })

     describe('AC2: Duplicate email rejection', () => {
       it('should reject registration with existing email', async () => {
         // Given: An email already registered
         // TODO: Create existing user

         // When: New user tries same email
         // TODO: Attempt duplicate registration

         // Then: Registration fails with error
         // TODO: Assert appropriate error response
         expect(true).toBe(false) // Placeholder - implement test
       })
     })
   })
   ```

6. **Generate test index** (if multiple stories):

   Create `tests/spec-coverage.md`:

   ```markdown
   # Test Coverage: [FEATURE]

   | Story | Criteria | Tests | Status   |
   | ----- | -------- | ----- | -------- |
   | US1   | 5        | 5     | Scaffold |
   | US2   | 3        | 3     | Scaffold |
   | US3   | 4        | 4     | Scaffold |

   ## Files Generated

   - tests/us1-user-registration.test.ts
   - tests/us2-password-reset.test.ts
   - tests/us3-session-management.test.ts
   ```

7. **Report**:
   - Tests generated: N files, M test cases
   - Framework detected: {framework}
   - Coverage: All acceptance criteria have test scaffolds
   - Next: Implement tests, then run `/speckit.implement`

## Key Rules

- **TDD enablement**: Tests exist before implementation
- **1:1 mapping**: Every acceptance criterion → one test case
- **Framework detection**: Don't assume, detect from project
- **Placeholder assertions**: `expect(true).toBe(false)` forces implementation
- **Spec traceability**: Comments link back to story/criterion IDs
