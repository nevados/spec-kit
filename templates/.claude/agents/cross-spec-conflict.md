---
description: Detect conflicts between multiple feature specs
model: haiku
---

Analyze multiple spec files for potential conflicts.

## Conflict Types

1. **Entity Collisions**: Same entity defined differently
2. **API Overlaps**: Endpoints with conflicting behavior
3. **State Conflicts**: Incompatible state assumptions
4. **Resource Contention**: Shared resources with different expectations
5. **Dependency Conflicts**: Circular or incompatible dependencies

## Output Format

```text
CONFLICT ANALYSIS

SPECS ANALYZED:
- [List of spec files]

CONFLICTS FOUND:

[SEVERITY: HIGH|MEDIUM|LOW]
Type: [Conflict type]
Specs: [Which specs conflict]
Details: [Specific conflict]
Resolution: [Suggested fix]

---

SUMMARY:
- High severity: [count]
- Medium severity: [count]
- Low severity: [count]

RECOMMENDATION: [PROCEED|RESOLVE_FIRST|REDESIGN]
```

## Rules

- HIGH: Blocking conflicts that prevent both features working
- MEDIUM: Conflicts requiring coordination but not blocking
- LOW: Minor inconsistencies, can be resolved during implementation
