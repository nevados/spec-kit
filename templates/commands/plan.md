---
description: Generate technical plan with research, architecture, and design artifacts
handoffs:
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break plan into executable tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Generate validation checklist
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## Input

```text
$ARGUMENTS
```

## Execution

1. **Setup**: Run `{SCRIPT}` for paths (FEATURE_SPEC, IMPL_PLAN, SPECS_DIR,
   BRANCH)

2. **Spec Quality Gate** (Task agent with haiku):

   **Quality Analysis Agent**:
   - Task: "Analyze spec quality. Score 1-10 for completeness, clarity,
     testability. Flag vague terms, missing sections, unmeasurable criteria."
   - Input: spec.md
   - Output: Scores (1-10 each), critical issues list, PASS/WARN/BLOCK
   - Token: <2K

   **If BLOCK** (any score < 5 or critical issues):

   ```markdown
   ## Spec Quality Gate: BLOCKED

   | Dimension    | Score | Issue                             |
   | ------------ | ----- | --------------------------------- |
   | Completeness | 4/10  | Missing edge cases, no priorities |
   | Clarity      | 3/10  | 5 vague terms, 2 placeholders     |
   | Testability  | 7/10  | -                                 |

   **Action Required**: Run `/speckit.clarify` to resolve issues before
   planning.
   ```

   **Stop execution** - do not proceed to planning.

   **If WARN** (scores 5-7): Display warnings, ask user to proceed or fix. **If
   PASS** (all scores > 7): Continue silently.

3. **Load**: Read FEATURE_SPEC, `/memory/constitution.md`, plan template

4. **Fill Technical Context**:
   - Stack (language, dependencies, storage, testing, platform)
   - Project type (single/web/mobile)
   - Performance/scale targets
   - Mark unknowns as "NEEDS CLARIFICATION"

5. **Constitution Check**: Evaluate gates from constitution, ERROR if violations
   unjustified

6. **Phase 0: Research** (use Task tool):
   - Extract all NEEDS CLARIFICATION items
   - Launch parallel Explore agents (haiku):
     - One agent per unknown
     - Prompt: "Research {unknown} for {feature}. Return: Decision, rationale
       (2-3 sentences), alternatives (bulleted)."
   - Consolidate → `research.md` (Decision → Rationale → Alternatives format)
   - All NEEDS CLARIFICATION must be resolved

7. **Phase 1: Design**: a. Extract entities from spec → `data-model.md`:
   - Entity, fields, relationships
   - Validation rules
   - State transitions

   b. Generate contracts from requirements:
   - Each user action → endpoint
   - REST/GraphQL patterns
   - Output to `/contracts/`

   c. Create `quickstart.md` (minimal validation steps)

   d. Update agent context:
   - Run `{AGENT_SCRIPT}`
   - Adds new tech to agent-specific file
   - Preserves manual additions

8. **Re-evaluate Constitution Check** post-design

9. **Report**: Branch, plan path, generated artifacts (research.md,
   data-model.md, contracts/, quickstart.md)

## Key Rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
- Token optimization: Agents return summaries only (not full docs)
- Use haiku for fast exploration
