---
description: Execute implementation plan by processing tasks.md
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps:
    scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## Input

```text
$ARGUMENTS
```

## Execution

1. **Initialize**: Run `{SCRIPT}` for FEATURE_DIR, AVAILABLE_DOCS

2. **Readiness validation** (parallel Task agents with haiku):

   **Agent 1 - Spec validation:** "Check spec.md: All stories prioritized?
   Acceptance criteria testable? Any NEEDS CLARIFICATION remaining? Return:
   PASS/FAIL with issues."

   **Agent 2 - Plan validation:** "Check plan.md: Tech stack complete (no
   placeholders)? Project structure defined? Constitution gates passed? Return:
   PASS/FAIL with issues."

   **Agent 3 - Tasks validation:** "Check tasks.md: All stories have tasks?
   Dependencies marked? File paths specified? Return: PASS/FAIL with issues."

   **If any FAIL**:

   ```markdown
   ## Readiness Check: NOT READY

   | Artifact | Status | Issues                |
   | -------- | ------ | --------------------- |
   | spec.md  | PASS   | -                     |
   | plan.md  | FAIL   | 2 placeholders remain |
   | tasks.md | PASS   | -                     |

   **Blocking**: Resolve plan.md placeholders before implementation. Run
   `/speckit.clarify` or `/speckit.plan` to fix.
   ```

   **Stop execution** - do not proceed to implementation.

   **If all PASS**: Continue to next step.

3. **Check checklists** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files, count total/completed/incomplete
   - Create status table:

     ```markdown
     | Checklist | Total | Completed | Incomplete | Status | | ux.md | 12 | 12 |
     0 | ✓ PASS |
     ```

   - **If any incomplete**: Display table, ASK "Proceed anyway? (yes/no)", wait
     for response
   - **If all complete**: Display table, proceed automatically

4. **Load context** (Task agents with sonnet):
   - "Analyze tasks.md: total tasks, tasks by phase, parallel groups,
     dependencies. Return JSON."
   - "Extract from plan.md: tech stack, file structure, critical dependencies.
     Max 300 words."
   - Optional: data-model.md, contracts/, research.md summaries (150 words each)

   **Model rationale**: Sonnet for detailed code understanding during
   implementation.

5. **Project setup verification**:
   - Detect project type: `git rev-parse --git-dir 2>/dev/null` → create/verify
     .gitignore
   - Check Dockerfile\* or plan.md mentions Docker → .dockerignore
   - Check .eslintrc\* / eslint.config.\* → .eslintignore / ignores config
   - Check .prettierrc\* → .prettierignore
   - Check package.json → .npmignore (if publishing)
   - Check \*.tf → .terraformignore
   - Check helm charts → .helmignore

   **Patterns by tech** (from plan.md):
   - Node.js/JS/TS: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - Python: `__pycache__/`, `*.pyc`, `.venv/`, `dist/`, `*.egg-info/`
   - Universal: `.DS_Store`, `*.tmp`, `.vscode/`, `.idea/`

6. **Parse tasks.md**:
   - Extract phases: Setup, Foundation, User Stories, Polish
   - Extract dependencies: sequential vs parallel [P]
   - Extract task details: ID, description, file paths

7. **Execute implementation**:
   - **Phase-by-phase**: Complete each before next
   - **Respect dependencies**: Sequential in order, parallel [P] together
   - **TDD**: Test tasks before implementation tasks
   - **File coordination**: Same-file tasks run sequentially
   - **Checkpoints**: Verify phase completion

8. **Execution flow**:
   - Setup: Init structure, dependencies, config
   - Foundation: Core infrastructure (blocks all stories)
   - User Stories: Models → Services → Endpoints → Integration
   - Polish: Tests (if requested), optimization, docs

9. **Progress tracking**:
   - Report after each task
   - Halt if non-parallel task fails
   - Continue parallel [P] if some fail, report failed ones
   - **Mark tasks [X] in tasks.md when complete**

10. **Completion**:
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
