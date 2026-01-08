---
name: drift-detection
description: Detects implementation drift from specification
allowed-tools: Read, Grep, Glob, Bash
---

# Drift Detection Skill

Compare implementation against spec to identify divergence.

## Detection Categories

### Scope Creep

- Features implemented but not in spec
- Extra endpoints or routes
- Additional data fields
- Unspecified behaviors

### Missing Implementation

- Spec requirements not implemented
- Partial acceptance criteria coverage
- Skipped edge cases
- Incomplete user stories

### Specification Deviation

- Implementation differs from spec intent
- Modified behaviors
- Changed data structures
- Altered workflows

## Analysis Process

1. Load spec.md acceptance criteria
2. Scan implementation files
3. Cross-reference requirements to code
4. Identify gaps and additions

## Output Format

```markdown
## Drift Analysis

**Status**: ALIGNED | DRIFT_WARNING | DRIFT_CRITICAL

### Scope Creep (Additions not in spec)

| Item                | Location          | Impact |
| ------------------- | ----------------- | ------ |
| Extra auth endpoint | routes/auth.ts:45 | Medium |

### Missing Coverage

| Requirement | Spec Reference | Status          |
| ----------- | -------------- | --------------- |
| FR-003      | spec.md:L120   | Not implemented |

### Deviations

| Spec Intent   | Actual Implementation | Severity |
| ------------- | --------------------- | -------- |
| JSON response | XML response          | High     |
```

## Severity Rules

- **ALIGNED**: No drift detected
- **DRIFT_WARNING**: Minor additions or low-impact gaps
- **DRIFT_CRITICAL**: Missing core requirements or major scope creep
