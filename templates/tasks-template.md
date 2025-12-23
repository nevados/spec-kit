# Tasks: [FEATURE NAME]

**Input**: `specs/[###-feature-name]/` design docs
**Prerequisites**: plan.md, spec.md (required); research.md, data-model.md, contracts/ (optional)

## Format: `- [ ] [ID] [P?] [Story] Description with file path`

- **[P]**: Parallelizable (different files, no dependencies)
- **[Story]**: User story (US1, US2, US3...)
- Include exact file paths

## Phase 1: Setup

- [ ] T001 Create project structure per plan.md
- [ ] T002 Initialize [language] with [framework] dependencies
- [ ] T003 [P] Configure linting/formatting

## Phase 2: Foundation

<!-- markdownlint-disable-next-line MD036 -->
**CRITICAL: Blocks all user stories**

- [ ] T004 Setup database schema/migrations
- [ ] T005 [P] Implement auth/authz framework
- [ ] T006 [P] Setup API routing/middleware
- [ ] T007 Create base models/entities
- [ ] T008 Configure error handling/logging

**Checkpoint**: Foundation complete - user stories can proceed

## Phase 3: US1 - [Title] (P1) 🎯 MVP

**Goal**: [What this story delivers]
**Test**: [How to verify independently]

### Tests (Optional - only if requested)

- [ ] T010 [P] [US1] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T011 [P] [US1] Integration test for [journey] in tests/integration/test_[name].py

### Implementation

- [ ] T012 [P] [US1] Create [Entity1] in src/models/[entity1].py
- [ ] T013 [P] [US1] Create [Entity2] in src/models/[entity2].py
- [ ] T014 [US1] Implement [Service] in src/services/[service].py
- [ ] T015 [US1] Implement [endpoint] in src/[location]/[file].py
- [ ] T016 [US1] Add validation/error handling
- [ ] T017 [US1] Add logging

**Checkpoint**: US1 independently functional

## Phase 4: US2 - [Title] (P2)

[Same structure as Phase 3]

## Phase N: Polish

- [ ] TXXX [P] Documentation in docs/
- [ ] TXXX Code cleanup/refactoring
- [ ] TXXX Performance optimization
- [ ] TXXX [P] Unit tests (if requested)
- [ ] TXXX Run quickstart.md validation

## Dependencies

**Phase Order**: Setup → Foundation (BLOCKS) → User Stories (parallel) → Polish

**Within Story**: Tests (fail first) → Models → Services → Endpoints

**Parallel**: All [P] tasks run together

## Implementation Strategy

### MVP First

1. Setup + Foundation
2. US1 only
3. Validate independently
4. Deploy/demo

### Incremental

1. Foundation
2. Add US1 → validate → deploy
3. Add US2 → validate → deploy
4. Each story adds value independently
