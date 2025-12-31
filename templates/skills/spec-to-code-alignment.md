# Spec-to-Code Alignment Skill

**Auto-invoke when:** User mentions checking implementation against spec, or
asks if code matches requirements.

**Trigger patterns:**

- "Does the code match the spec?"
- "Verify implementation against specification"
- "Check if we implemented all requirements"
- "Compare code to spec"
- "Implementation coverage check"

## Purpose

Validate that implemented code satisfies all specification requirements without
manually reading every file. Uses agent delegation for efficient verification.

## Alignment Checks

### 1. Requirement Coverage

**Question**: Does every FR-### have corresponding implementation?

**Agent Strategy** (Haiku):

```text
"Extract all FR-### from spec.md (functional requirements).
For each FR, search codebase for implementation evidence.
Return: requirement ID | implemented (yes/no) | file path if found"
```

### 2. User Story Completion

**Question**: Are all user stories fully implemented?

**Agent Strategy** (Haiku):

```text
"Extract user stories from spec.md with priorities.
Check git diff or tasks.md for completion status.
Return: story ID | priority | status (complete/partial/missing) | completion %"
```

### 3. Acceptance Criteria Validation

**Question**: Does code satisfy acceptance criteria?

**Agent Strategy** (Sonnet):

```text
"For each user story in spec.md, extract acceptance criteria.
Analyze implementation files to verify each criterion is met.
Return: story ID | criterion | satisfied (yes/no/partial) | evidence"
```

### 4. Edge Case Handling

**Question**: Are edge cases from spec addressed in code?

**Agent Strategy** (Sonnet):

```text
"Extract edge cases from spec.md.
Search implementation for error handling, validation, boundary checks.
Return: edge case | handled (yes/no) | implementation location"
```

## Execution Strategy

**Use parallel agents for comprehensive coverage:**

**Phase 1: Fast Coverage Check** (Haiku agents)

- Agent 1: Requirement coverage (FR-### mapping)
- Agent 2: User story completion status
- ~2 minutes, ~4K tokens total

**Phase 2: Deep Validation** (Sonnet agents - if needed)

- Agent 3: Acceptance criteria verification
- Agent 4: Edge case handling check
- ~5 minutes, ~12K tokens total

## Output Format

```markdown
# Spec-to-Code Alignment Report

**Branch**: 042-user-authentication **Spec**:
specs/042-user-authentication/spec.md **Coverage**: 18/20 requirements (90%)

## Requirement Coverage

| Requirement                | Status     | Implementation           |
| -------------------------- | ---------- | ------------------------ |
| FR-001: User registration  | ✓ Complete | `auth-service.js:45-89`  |
| FR-002: Email validation   | ✓ Complete | `validators/email.js:12` |
| FR-003: Password hashing   | ✓ Complete | `auth-service.js:92`     |
| FR-004: Login endpoint     | ✓ Complete | `routes/auth.js:34`      |
| FR-005: Password reset     | ✗ Missing  | Not implemented          |
| FR-006: Session management | ⚠ Partial | Missing timeout logic    |

## User Story Completion

| Story               | Priority | Status     | Tasks | Acceptance Criteria |
| ------------------- | -------- | ---------- | ----- | ------------------- |
| US1: Basic Auth     | P1       | ✓ Complete | 8/8   | 5/5 met             |
| US2: Password Reset | P2       | ✗ Missing  | 0/5   | 0/3 met             |
| US3: Session Mgmt   | P2       | ⚠ Partial | 4/6   | 2/4 met             |

## Acceptance Criteria Gaps

### US3: Session Management (Partial)

- ✓ AC1: Users can login and receive session token
- ✓ AC2: Session tokens expire after inactivity
- ✗ AC3: Users can logout and invalidate session
- ✗ AC4: Session renewal on continued activity

**Missing**: Logout endpoint and session renewal logic

## Edge Cases

| Edge Case                 | Handled? | Implementation                              |
| ------------------------- | -------- | ------------------------------------------- |
| Concurrent login attempts | ✓ Yes    | Rate limiting in `middleware/rate-limit.js` |
| Invalid email format      | ✓ Yes    | Validator in `validators/email.js`          |
| Weak password             | ✓ Yes    | Strength check in `validators/password.js`  |
| Duplicate registration    | ✗ No     | No unique constraint error handling         |

## Summary

**Alignment Score**: 75/100

**Blocking Issues**: 1

- Missing FR-005 (Password Reset) - P2 priority

**High Priority**: 2

- US3 acceptance criteria not fully met
- Duplicate registration edge case not handled

**Recommendations**:

1. Implement password reset flow (FR-005, US2)
2. Add logout endpoint and session renewal (US3)
3. Handle duplicate registration gracefully

**Next Steps**:

- Run `/speckit.implement` to complete US2 and US3
- Or run `/speckit.review` for detailed analysis
```

## Model Usage

**Phase 1** (always run):

- Haiku × 2 agents = ~4K tokens
- Fast coverage assessment

**Phase 2** (conditional):

- Sonnet × 2 agents = ~12K tokens
- Only if Phase 1 shows gaps or user requests deep validation

## Token Optimization

**Traditional approach** (load all files):

- Read spec.md: 3K tokens
- Read 15+ implementation files: 45K tokens
- Analyze in main conversation: 10K tokens
- **Total**: 58K tokens

**With skill** (agent delegation):

- Agent Phase 1 summaries: 4K tokens
- Agent Phase 2 summaries: 12K tokens (if needed)
- Main conversation analysis: 2K tokens
- **Total**: 6-18K tokens (69-90% reduction)
