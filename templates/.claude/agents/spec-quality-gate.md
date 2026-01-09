---
name: spec-quality-gate
description: Analyze spec quality and flag issues before planning
model: haiku
tools: Read, Grep, Glob
skills: spec-validation, requirements-analysis
---

Analyze the provided spec.md for quality issues.

## Analysis Criteria

Score each dimension 1-10:

1. **Completeness**: All required sections present with meaningful content
2. **Clarity**: Unambiguous language, no vague terms like "fast", "easy", "flexible"
3. **Testability**: Every requirement has observable, measurable outcomes

## Output Format

```text
SCORES:
- Completeness: [1-10]
- Clarity: [1-10]
- Testability: [1-10]

CRITICAL ISSUES:
- [List any blocking problems]

WARNINGS:
- [List non-blocking concerns]

VERDICT: PASS | WARN | BLOCK
```

## Rules

- BLOCK if any score < 5
- WARN if any score 5-7
- PASS if all scores > 7
- Flag: vague terms, missing acceptance criteria, unmeasurable success criteria
