# Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Spec**: [link]

## Summary

[Primary requirement + technical approach in 2-3 sentences]

## Stack

**Language**: [e.g., Python 3.11, Node 20]
**Dependencies**: [e.g., FastAPI, Express]
**Storage**: [e.g., PostgreSQL, Redis, N/A]
**Testing**: [e.g., pytest, jest]
**Platform**: [e.g., Linux, iOS 15+, web]
**Type**: [single/web/mobile]

## Constitution Check

*GATE: Must pass before research. Re-check after design.*

[Gates from constitution file]

## Structure

**Docs**: `specs/[###-feature]/`

**Code**: [Choose one]

```text
# Single Project
src/ → models/, services/, cli/
tests/ → contract/, integration/, unit/

# Web App
backend/src/ → models/, services/, api/
frontend/src/ → components/, pages/, services/

# Mobile
api/ → [backend structure]
[ios|android]/ → [platform structure]
```

## Complexity Tracking

> **Fill ONLY if Constitution violations require justification**

| Violation | Why Needed | Alternative Rejected |
|-----------|------------|---------------------|
| [violation] | [reason] | [why simpler approach insufficient] |

## Phase 0: Research

[Results from exploration agents - decisions, rationale, alternatives]

## Phase 1: Design

### Data Model

[Entities, fields, relationships from spec]

### Contracts

[API endpoints/interfaces mapped from requirements]

### Quickstart

[Minimal steps to validate implementation]
