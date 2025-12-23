# Implementation Readiness Skill

**Auto-invoke when:** User asks if a feature is ready for implementation or wants to start coding.

**Trigger patterns:**

- "Is this ready to implement?"
- "Can I start coding now?"
- "Should I begin implementation?"
- "Are we ready to build this?"
- "Check implementation readiness"

## Purpose

Validate that all prerequisite artifacts exist and meet quality standards before implementation begins, preventing costly rework.

## Prerequisites Check

**Required artifacts:**

1. ✓ spec.md - Feature specification
2. ✓ plan.md - Technical implementation plan
3. ✓ tasks.md - Actionable task breakdown

**Optional but recommended:**
4. research.md - Technical decisions documented
5. data-model.md - Entities and relationships defined
6. contracts/ - API specifications (if applicable)
7. checklists/ - Quality validation checklists

## Validation Criteria

### Spec Quality (Must Pass)

- All user stories have priorities
- Acceptance criteria are testable
- Edge cases documented
- No NEEDS CLARIFICATION placeholders

### Plan Completeness (Must Pass)

- Tech stack specified (no placeholders)
- Project structure defined
- Constitution check passed
- All research.md items resolved

### Task Breakdown (Must Pass)

- Tasks mapped to user stories
- Dependencies clearly marked
- File paths specified for each task
- Parallel opportunities identified

## Execution Strategy

**Use multiple parallel Haiku agents for fast validation:**

**Agent 1 - Spec Validation:**

```text
"Check spec.md: All stories prioritized? Acceptance criteria testable?
Any placeholders remaining? Return: PASS/FAIL with issues list."
```

**Agent 2 - Plan Validation:**

```text
"Check plan.md: Tech stack complete? Project structure defined?
Constitution gates passed? Return: PASS/FAIL with issues list."
```

**Agent 3 - Task Validation:**

```text
"Check tasks.md: All stories have tasks? Dependencies marked?
File paths specified? Return: PASS/FAIL with issues list."
```

## Output Format

```markdown
# Implementation Readiness Report

**Overall Status**: READY / NOT READY / READY WITH WARNINGS

## Artifacts Status
✓ spec.md (complete)
✓ plan.md (complete)
✓ tasks.md (complete)
✓ research.md (complete)
⚠ checklists/ (recommended but missing)

## Validation Results

### Spec Quality: PASS ✓
- All user stories prioritized (P1-P3)
- Acceptance criteria testable
- Edge cases documented

### Plan Completeness: PASS ✓
- Tech stack: Node.js 20, PostgreSQL 15, Vite 5
- Project structure: web application (frontend/backend)
- Constitution check: PASSED

### Task Breakdown: PASS ✓
- 45 tasks across 8 phases
- All user stories covered
- Dependencies clearly marked
- 12 parallel opportunities identified

## Recommendations
1. ✓ Run `/speckit.checklist` to generate quality checklists
2. ✓ Review constitution compliance in plan.md
3. Ready to run `/speckit.implement`

**Next Command**: `/speckit.implement`
```

## Blocking Issues

If validation fails, provide specific remediation:

```markdown
## Blocking Issues

### CRITICAL
- [ ] spec.md missing User Story 3 acceptance criteria
- [ ] plan.md has 2 NEEDS CLARIFICATION placeholders
- [ ] tasks.md Phase 4 tasks have no file paths

### Remediation Steps
1. Run `/speckit.clarify` to resolve placeholders
2. Update spec.md with missing acceptance criteria
3. Run `/speckit.tasks` to regenerate with file paths

**Cannot proceed with implementation until these are resolved.**
```

## Model Usage

- **Haiku** for all validation checks (3 parallel agents)
- Total token budget: ~3K tokens
- Execution time: <10 seconds
