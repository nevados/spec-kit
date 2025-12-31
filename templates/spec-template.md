# Feature: [FEATURE NAME]

**Branch**: `[###-feature-name]` | **Status**: Draft | **Created**: [DATE]

<!-- GUIDANCE: Focus on WHAT and WHY, never HOW. No tech details. -->

## User Stories

<!-- Each story = standalone slice: develop, test, deploy, demo independently -->

### US1: [Title] (P1)

[User journey: who does what, why they need it, value delivered]

**Acceptance**:

1. **Given** [precondition], **When** [action], **Then** [observable outcome]
2. **Given** [precondition], **When** [action], **Then** [observable outcome]

**Test independently**: [How to verify this story works in isolation]

### US2: [Title] (P2)

[User journey: who does what, why they need it, value delivered]

**Acceptance**:

1. **Given** [precondition], **When** [action], **Then** [observable outcome]

**Test independently**: [How to verify this story works in isolation]

### US3: [Title] (P3)

[Lower priority - nice to have]

**Acceptance**:

1. **Given** [precondition], **When** [action], **Then** [observable outcome]

### Edge Cases

<!-- Boundary conditions, error scenarios, empty states -->

- [Invalid input]: [Expected behavior]
- [Empty state]: [Expected behavior]
- [Concurrent access]: [Expected behavior]

## Requirements

**Functional**:

<!-- MUST = required, SHOULD = recommended, MAY = optional -->

- **FR-001**: System MUST [specific, testable capability]
- **FR-002**: System MUST [specific, testable capability]
- **FR-003**: Users MUST be able to [specific interaction]
- **FR-004**: System SHOULD [recommended capability]
- **FR-005**: [NEEDS CLARIFICATION: what decision is needed?]

**Non-Functional** _(if applicable)_:

- **NFR-001**: [Performance/security/accessibility requirement]

**Entities** _(if data involved)_:

- **[Entity1]**: [Purpose] - key attrs: [list], relates to: [other entities]
- **[Entity2]**: [Purpose] - key attrs: [list], relates to: [other entities]

## Success Criteria

<!-- Measurable, user-focused, tech-agnostic. No "API response time" -->

- **SC-001**: [User task] completes in under [time] for [percentage] of users
- **SC-002**: System handles [volume] concurrent [operations] without
  degradation
- **SC-003**: [User satisfaction metric]: [target]
- **SC-004**: [Business impact]: [measurable reduction/increase]

## Assumptions

<!-- Document what you assumed when unclear -->

- [Assumption about scope/behavior/constraints]

## Out of Scope

<!-- Explicitly exclude to prevent scope creep -->

- [Feature/capability NOT included in this spec]
