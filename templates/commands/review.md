---
description: Verify implementation matches spec and identify gaps
handoffs:
  - label: Fix Issues
    agent: speckit.implement
    prompt: Address review findings
    send: false
  - label: Update Spec
    agent: speckit.specify
    prompt: Update spec from implementation learnings
    send: false
scripts:
  sh: scripts/bash/gather-review-context.sh --json
  ps: scripts/powershell/gather-review-context.ps1 -Json
---

## Input

```text
$ARGUMENTS
```

## Execution

1. **Initialize**: Run `{SCRIPT}` for FEATURE_DIR, FEATURE_SPEC, IMPL_PLAN, TASKS, GIT_DIFF_FILES, task counts

2. **Determine scope**:
   - Complete: All tasks marked [X]
   - Partial: Some incomplete
   - None: No changes detected → "No implementation to review" → exit

3. **Multi-agent analysis** (parallel Task tool):

   **Spec Coverage Agent** (haiku - fast):
   - Task: "Verify all user stories have tasks"
   - Input: spec.md (user stories), tasks.md
   - Output: Stories with/without coverage
   - Token: <2K

   **Acceptance Criteria Agent** (haiku):
   - Task: "Map acceptance criteria to completed tasks"
   - Input: spec.md (criteria), tasks.md (completed)
   - Output: Criteria→tasks table, unmapped flags
   - Token: <3K

   **Code Review Agent** (sonnet - detailed):
   - Task: "Review files against plan/spec"
   - Input: plan.md (architecture), GIT_DIFF_FILES (paths only), spec.md
   - Instructions: "Use file paths and git diff stats only, NOT full contents"
   - Output: Files with alignment status, deviations
   - Token: <8K

   **Test Coverage Agent** (haiku):
   - Task: "Verify test coverage per story (if tests requested)"
   - Input: tasks.md (test tasks), GIT_DIFF_FILES (test files)
   - Output: Coverage report per story
   - Token: <2K
   - Skip if no test tasks exist

   **Token target**: <20K total

4. **Consolidate findings** by severity:
   - **CRITICAL**: Missing acceptance criteria, no user story implementation
   - **HIGH**: Architectural deviation, missing required tests
   - **MEDIUM**: Incomplete implementation, partial coverage
   - **LOW**: Documentation gaps, naming inconsistencies

5. **Generate review.md**:

   ```markdown
   # Implementation Review: [FEATURE]

   **Reviewer**: Claude Sonnet 4.5 (automated)
   **Scope**: [Full | Partial - N/M tasks]

   ## Summary
   - **Status**: [PASS | PASS WITH CONCERNS | FAIL]
   - **Completion**: X% stories implemented
   - **Critical Issues**: N
   - **Test Coverage**: X% (if applicable)

   ## User Story Review
   | Story | Status | Tasks | Criteria Met | Issues |
   |-------|--------|-------|--------------|--------|
   | US1   | ✓      | 8/8   | 5/5          | None   |

   ## Findings by Severity
   ### CRITICAL
   **C1: [Issue]**
   - Location: [file:line]
   - Expected: [what]
   - Actual: [what]
   - Impact: [impact]
   - Recommendation: [action]

   ## Acceptance Criteria Coverage
   ### US1: [Title]
   - ✓ AC1: [criterion]
   - ✗ AC2: [criterion] (NOT IMPLEMENTED)

   ## Recommendations
   ### Immediate (Before Deployment)
   1. [Action]

   ### Next Steps
   - [ ] Address CRITICAL findings
   - [ ] Re-run `/speckit.review`
   ```

6. **Report**:
   - Summary stats (findings, critical count, coverage %)
   - Next action based on findings:
     - CRITICAL: "Run /speckit.implement to address"
     - None: "Ready for deployment"
     - HIGH/MEDIUM: "Consider addressing"

## Key Principles

- **Token efficiency**: Haiku for mapping (<3K each), Sonnet for arch review (~8K)
- **Never load full files**: Use git diff stats and paths only
- **Actionable**: Every finding has location + recommendation
- **Non-blocking**: Review never modifies code
- **Objective**: Task completion, file existence, test presence (no subjective quality)
- **Deterministic**: Same state → consistent findings
