---
name: requirements-analysis
description: Extracts and analyzes requirements from specifications
allowed-tools: Read, Grep
---

# Requirements Analysis Skill

Extract structured requirements data from specification documents.

## Extraction Targets

### Functional Requirements (FR-###)

- Identify numbered requirements
- Extract description and rationale
- Note dependencies between requirements
- Flag any gaps in numbering

### User Stories

- Extract actor, action, benefit format
- Identify priority (Must/Should/Could)
- Link to acceptance criteria
- Note story dependencies

### Acceptance Criteria

- Extract testable conditions
- Identify measurable outcomes
- Link to parent stories
- Flag vague criteria

### Edge Cases

- Identify boundary conditions
- Extract error scenarios
- Note recovery behaviors
- Flag missing edge cases

## Output Format

```markdown
## Requirements Inventory

| ID     | Type       | Description | Priority | Dependencies |
| ------ | ---------- | ----------- | -------- | ------------ |
| FR-001 | Functional | ...         | Must     | -            |
| US-001 | User Story | ...         | Must     | FR-001       |

## Coverage Analysis

- Total Requirements: N
- With Acceptance Criteria: N (%)
- Edge Cases Documented: N
- Gaps Identified: N
```
