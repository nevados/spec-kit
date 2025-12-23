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

1. **Setup**: Run `{SCRIPT}` for paths (FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH)

2. **Load**: Read FEATURE_SPEC, `/memory/constitution.md`, plan template

3. **Fill Technical Context**:
   - Stack (language, dependencies, storage, testing, platform)
   - Project type (single/web/mobile)
   - Performance/scale targets
   - Mark unknowns as "NEEDS CLARIFICATION"

4. **Constitution Check**: Evaluate gates from constitution, ERROR if violations unjustified

5. **Phase 0: Research** (use Task tool):
   - Extract all NEEDS CLARIFICATION items
   - Launch parallel Explore agents (haiku):
     - One agent per unknown
     - Prompt: "Research {unknown} for {feature}. Return: Decision, rationale (2-3 sentences), alternatives (bulleted)."
   - Consolidate → `research.md` (Decision → Rationale → Alternatives format)
   - All NEEDS CLARIFICATION must be resolved

6. **Phase 1: Design**:
   a. Extract entities from spec → `data-model.md`:
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

7. **Re-evaluate Constitution Check** post-design

8. **Report**: Branch, plan path, generated artifacts (research.md, data-model.md, contracts/, quickstart.md)

## Key Rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
- Token optimization: Agents return summaries only (not full docs)
- Use haiku for fast exploration
