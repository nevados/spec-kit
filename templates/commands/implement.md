---
description: Execute implementation plan by processing tasks.md
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## Input

```text
$ARGUMENTS
```

## Execution

1. **Initialize**: Run `{SCRIPT}` for FEATURE_DIR, AVAILABLE_DOCS

2. **Check checklists** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files, count total/completed/incomplete
   - Create status table:
     ```
     | Checklist | Total | Completed | Incomplete | Status |
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     ```
   - **If any incomplete**: Display table, ASK "Proceed anyway? (yes/no)", wait for response
   - **If all complete**: Display table, proceed automatically

3. **Load context** (Task agents with sonnet):
   - "Analyze tasks.md: total tasks, tasks by phase, parallel groups, dependencies. Return JSON."
   - "Extract from plan.md: tech stack, file structure, critical dependencies. Max 300 words."
   - Optional: data-model.md, contracts/, research.md summaries (150 words each)

   **Model rationale**: Sonnet for detailed code understanding during implementation.

4. **Project setup verification**:
   - Detect project type: `git rev-parse --git-dir 2>/dev/null` → create/verify .gitignore
   - Check Dockerfile* or plan.md mentions Docker → .dockerignore
   - Check .eslintrc* / eslint.config.* → .eslintignore / ignores config
   - Check .prettierrc* → .prettierignore
   - Check package.json → .npmignore (if publishing)
   - Check *.tf → .terraformignore
   - Check helm charts → .helmignore

   **Patterns by tech** (from plan.md):
   - Node.js/JS/TS: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - Python: `__pycache__/`, `*.pyc`, `.venv/`, `dist/`, `*.egg-info/`
   - Universal: `.DS_Store`, `*.tmp`, `.vscode/`, `.idea/`

5. **Parse tasks.md**:
   - Extract phases: Setup, Foundation, User Stories, Polish
   - Extract dependencies: sequential vs parallel [P]
   - Extract task details: ID, description, file paths

6. **Execute implementation**:
   - **Phase-by-phase**: Complete each before next
   - **Respect dependencies**: Sequential in order, parallel [P] together
   - **TDD**: Test tasks before implementation tasks
   - **File coordination**: Same-file tasks run sequentially
   - **Checkpoints**: Verify phase completion

7. **Execution flow**:
   - Setup: Init structure, dependencies, config
   - Foundation: Core infrastructure (blocks all stories)
   - User Stories: Models → Services → Endpoints → Integration
   - Polish: Tests (if requested), optimization, docs

8. **Progress tracking**:
   - Report after each task
   - Halt if non-parallel task fails
   - Continue parallel [P] if some fail, report failed ones
   - **Mark tasks [X] in tasks.md when complete**

9. **Completion**:
   - Verify all tasks complete
   - Check features match spec
   - Validate tests pass
   - Confirm follows plan
   - **SUGGEST**: "Run /speckit.review to verify"

## Key Rules

- Assumes complete task breakdown exists
- If incomplete: suggest `/speckit.tasks` first
- Use sonnet for implementation (needs code understanding)
- Mark tasks complete in tasks.md as you go
