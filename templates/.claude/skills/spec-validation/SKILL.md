---
name: spec-validation
description: Validates specification quality and completeness
allowed-tools: Read, Grep, Glob
---

# Spec Validation Skill

Score specifications on three dimensions:

## 1. Completeness

- All mandatory sections present
- User stories with acceptance criteria
- Requirements prioritized
- Edge cases documented

## 2. Clarity

- No vague terms (fast, robust, scalable, easy)
- Specific metrics where applicable
- Unambiguous language
- No placeholder text

## 3. Testability

- Each requirement measurable
- Acceptance criteria objective
- Success criteria verifiable
- No subjective outcomes

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
