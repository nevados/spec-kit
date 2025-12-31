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
   - Primary: "Extract from plan.md and spec.md: tech stack, user stories with
     priorities (P1/P2/P3), project structure type. Return as table."
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

5. **Effort Scoring** (Task agent with haiku):

   Agent prompt: "Score each task by implementation effort:
   - S (Small): < 30 min, single file, straightforward
   - M (Medium): 30-60 min, 2-3 files, some complexity
   - L (Large): 1-2 hours, multiple files, dependencies
   - XL (Extra Large): 2+ hours, architectural, high risk

   Consider: file count, dependencies, testing needs, integration points.
   Return: task ID → effort score with brief rationale."

   Add effort to task format: `- [ ] [ID] [P?] [S|M|L|XL] Description`

   Generate effort summary:

   ```markdown
   ## Effort Summary

   | Size | Count | Examples                        |
   | ---- | ----- | ------------------------------- |
   | S    | 12    | Config, types, simple endpoints |
   | M    | 8     | Services, middleware            |
   | L    | 4     | Core features, integrations     |
   | XL   | 1     | Auth system                     |

   **Total Effort**: 25 tasks (12S + 8M + 4L + 1XL) **Complexity**: Medium-High
   (1 XL task, 4 L tasks) **Risk Areas**: Auth system (XL) - consider splitting
   ```

6. **Report**:
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
