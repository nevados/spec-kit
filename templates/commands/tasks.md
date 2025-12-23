---
description: Generate actionable, dependency-ordered tasks from design artifacts
handoffs:
  - label: Analyze Consistency
    agent: speckit.analyze
    prompt: Validate cross-artifact consistency
    send: true
  - label: Implement Project
    agent: speckit.implement
    prompt: Execute implementation
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## Input

```text
$ARGUMENTS
```

## Execution

1. **Setup**: Run `{SCRIPT}` for FEATURE_DIR and AVAILABLE_DOCS

2. **Load design docs** (use Task agents with haiku):
   - Primary: "Extract from plan.md and spec.md: tech stack, user stories with priorities (P1/P2/P3), project structure type. Return as table."
   - Optional (if exist):
     - data-model.md: "Extract entity names and relationships as table"
     - contracts/: "Extract endpoint→story mappings"
     - research.md: "Extract setup-critical decisions only"

3. **Generate tasks.md** using template:
   - Phase 1: Setup (project init)
   - Phase 2: Foundation (blocking prerequisites)
   - Phase 3+: User stories (one phase per story, in priority order)
   - Final: Polish & cross-cutting

   **Task format**: `- [ ] [ID] [P?] [Story?] Description with file path`
   - [P] = parallelizable
   - [Story] = US1, US2, US3...
   - Tests optional (only if requested)

4. **Organize by user story**:
   - Map entities → stories
   - Map endpoints → stories
   - Independent test criteria per story
   - Clear file paths for each task

5. **Report**:
   - Path to tasks.md
   - Total tasks, tasks per story
   - Parallel opportunities
   - MVP scope (typically US1 only)
   - Format validation: all tasks follow checklist format

## Key Rules

- Tasks organized by user story (independent implementation)
- Tests optional unless explicitly requested
- Use haiku agents for extraction (10x cheaper)
- Agents return structured data, not full files
- Each task immediately executable by LLM
