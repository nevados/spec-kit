---
description: Extract and structure acceptance criteria from specs
model: haiku
---

Parse spec.md and extract all acceptance criteria in structured format.

## Extraction Rules

1. Find all **Given/When/Then** patterns
2. Convert prose acceptance to G/W/T format if needed
3. Classify each criterion by test type

## Test Type Classification

- **Unit**: Single function/method behavior
- **Integration**: Multiple components working together
- **E2E**: Full user journey through system
- **Contract**: API boundary validation

## Output Format

```yaml
story: US1
title: [Story title]
criteria:
  - id: AC1
    given: [Precondition]
    when: [Action]
    then: [Expected outcome]
    test_type: [unit|integration|e2e|contract]

  - id: AC2
    given: [Precondition]
    when: [Action]
    then: [Expected outcome]
    test_type: [unit|integration|e2e|contract]
```

## Summary

```text
EXTRACTION COMPLETE

Stories: [count]
Total Criteria: [count]
By Type:
  - Unit: [count]
  - Integration: [count]
  - E2E: [count]
  - Contract: [count]
```
