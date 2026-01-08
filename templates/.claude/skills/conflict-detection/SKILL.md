---
name: conflict-detection
description: Detects conflicts between multiple feature specifications
allowed-tools: Read, Grep, Glob
---

# Conflict Detection Skill

Analyze multiple specs for cross-feature conflicts.

## Conflict Categories

### Entity Collisions

- Same model defined differently across specs
- Conflicting field types or constraints
- Incompatible relationships
- Duplicate entity names

### API Overlaps

- Conflicting endpoint paths
- Incompatible request/response schemas
- Duplicate route handlers
- Authorization conflicts

### State Conflicts

- Incompatible state machines
- Conflicting state transitions
- Shared state with different semantics
- Race conditions

### Resource Contention

- Shared database tables with different schemas
- Conflicting file paths
- Service port conflicts
- Environment variable collisions

### Dependency Conflicts

- Incompatible library versions
- Circular dependencies
- Missing shared dependencies
- Breaking API changes

## Analysis Process

1. Scan `specs/*/spec.md` for all feature specs
2. Extract entities, APIs, states, resources from each
3. Cross-reference for overlaps
4. Identify conflicts and suggest resolutions

## Output Format

```markdown
## Cross-Spec Conflict Analysis

**Specs Analyzed**: N
**Conflicts Found**: N

### Conflicts

| Specs                 | Type   | Conflict             | Severity | Resolution          |
| --------------------- | ------ | -------------------- | -------- | ------------------- |
| 001-auth, 003-profile | Entity | User model differs   | High     | Merge definitions   |
| 002-api, 004-webhook  | API    | Both use /api/events | Medium   | Namespace endpoints |

### Recommendations

1. [Specific resolution steps]
2. [Priority order]
```

## Severity Levels

- **Critical**: Blocks implementation of both features
- **High**: Requires spec changes before implementation
- **Medium**: Can proceed with awareness
- **Low**: Style/naming suggestions
