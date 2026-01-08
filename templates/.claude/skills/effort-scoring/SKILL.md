---
name: effort-scoring
description: Scores task effort for planning and estimation
allowed-tools: Read, Grep
---

# Effort Scoring Skill

Estimate task complexity and effort for sprint planning.

## Scoring Dimensions

### Complexity

- **Algorithmic**: Data structures, algorithms, performance
- **Integration**: External services, APIs, databases
- **UI/UX**: Frontend components, interactions, accessibility
- **Infrastructure**: Deployment, configuration, monitoring

### Scope

- **File Count**: Number of files to create/modify
- **Line Estimate**: Approximate lines of code
- **Test Coverage**: Tests required
- **Documentation**: Docs to update

### Risk Factors

- **New Patterns**: Introducing unfamiliar approaches
- **External Dependencies**: Third-party services, APIs
- **Breaking Changes**: Existing code modifications
- **Uncertainty**: Unknown requirements or approaches

## Size Categories

| Size   | Complexity | Files | Risk    | Typical Effort |
| ------ | ---------- | ----- | ------- | -------------- |
| **S**  | Low        | 1-2   | Low     | < 2 hours      |
| **M**  | Medium     | 3-5   | Low-Med | 2-8 hours      |
| **L**  | High       | 6-10  | Medium  | 1-3 days       |
| **XL** | Very High  | 10+   | High    | 3+ days        |

## Output Format

```markdown
## Effort Analysis

| Task  | Size | Complexity | Files | Risk   | Rationale                     |
| ----- | ---- | ---------- | ----- | ------ | ----------------------------- |
| T-001 | M    | Medium     | 4     | Low    | Standard CRUD, known patterns |
| T-002 | L    | High       | 8     | Medium | New auth flow, external API   |

### Summary

- Total Tasks: N
- S: N | M: N | L: N | XL: N
- High Risk Tasks: N
- Recommended Sprint Capacity: [based on sizes]
```

## Scoring Rules

- Base score on most complex dimension
- Increase for multiple risk factors
- Consider team familiarity
- Account for testing overhead
