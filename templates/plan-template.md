# Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Spec**: [link] | **Date**: [DATE]

<!-- Technical HOW for the spec's WHAT. Fill via /speckit.plan -->

## Summary

[Primary requirement + technical approach in 2-3 sentences]

## Stack

<!-- NEEDS CLARIFICATION if unknown - don't guess -->

| Aspect    | Choice                                |
| --------- | ------------------------------------- |
| Language  | [e.g., Python 3.11, Node 20, Go 1.21] |
| Framework | [e.g., FastAPI, Express, Gin]         |
| Storage   | [e.g., PostgreSQL 15, Redis, N/A]     |
| Testing   | [e.g., pytest, vitest, go test]       |
| Platform  | [e.g., Linux, iOS 15+, web]           |
| Type      | [single/web/mobile]                   |

**Performance**: [e.g., 1000 req/s, <200ms p95, or NEEDS CLARIFICATION]
**Scale**: [e.g., 10k users, 1M records, or NEEDS CLARIFICATION]

## Constitution Check

<!-- GATE: Must pass before research. Re-check after design. -->

| Principle                | Status    | Notes                   |
| ------------------------ | --------- | ----------------------- |
| [MUST from constitution] | PASS/FAIL | [justification if fail] |

## Structure

**Docs**: `specs/[###-feature]/` (spec, plan, tasks, research, contracts)

**Code** _(select one, delete others)_:

```text
# Single Project (DEFAULT)
src/models/, src/services/, src/cli/
tests/unit/, tests/integration/, tests/contract/

# Web App (frontend + backend)
backend/src/models/, backend/src/services/, backend/src/api/
frontend/src/components/, frontend/src/pages/

# Mobile + API
api/src/[backend structure]
[ios|android]/[platform structure]
```

## Complexity Tracking

<!-- Fill ONLY if Constitution violations need justification -->

| Violation           | Justification | Simpler Alternative Rejected |
| ------------------- | ------------- | ---------------------------- |
| [e.g., 4th service] | [why needed]  | [why 3 insufficient]         |

## Phase 0: Research

<!-- Output from Explore agents - decisions with rationale -->

### [Topic 1]

**Decision**: [chosen approach] **Rationale**: [2-3 sentences why]
**Alternatives**: [what was considered and rejected]

## Phase 1: Design

### Data Model

<!-- Entities from spec, with fields and relationships -->

| Entity    | Fields        | Relationships         |
| --------- | ------------- | --------------------- |
| [Entity1] | id, name, ... | belongs_to: [Entity2] |

### Contracts

<!-- API endpoints mapped from requirements -->

| Endpoint        | Method | Purpose         | Maps to |
| --------------- | ------ | --------------- | ------- |
| /api/[resource] | POST   | Create [entity] | FR-001  |

### Quickstart

<!-- Minimal steps to validate implementation works -->

1. [Setup step]
2. [Verification step]
3. [Expected outcome]
