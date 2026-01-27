---
description: Create feature specification from natural language description
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create technical plan for this spec
  - label: Clarify Requirements
    agent: speckit.clarify
    prompt: Clarify ambiguous requirements
    send: true
scripts:
  sh: scripts/bash/create-new-feature.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-feature.ps1 -Json "{ARGS}"
---

## Input

Optional parameters:

- `--type <type>` - Conventional commit type (default: feat)
  - Valid: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- `--short-name <name>` - Custom short name for the branch

Feature description:

```text
$ARGUMENTS
```

## Execution

1. **Session init**: Run bash command to mark active session:

```bash
mkdir -p .specify && touch .specify/.active-session
```

2. **Run setup script** (once only):

   ```bash
   {SCRIPT} --json "Feature description"
   ```

   Script will:
   - Generate branch name: `{type}/{slugified-description}` (e.g.,
     "feat/user-authentication")
   - Check if branch exists (auto-checkout if yes, create if no)
   - Create spec directory and template

   Parse JSON output for BRANCH_NAME, SPEC_FILE, COMMIT_TYPE

3. **Research codebase patterns** (use Task tool with Explore agent):

   **For greenfield** (no existing code):
   - Skip research, proceed to spec generation

   **For brownfield** (existing codebase): Launch parallel Explore agents
   (model: sonnet for code understanding):

   **Agent 1 - Feature location:** "Find files related to [feature area].
   Return: service files (paths), middleware (paths), routes/endpoints (paths),
   key functions (name + file:line). Max 200 words."

   **Agent 2 - Architecture patterns:** "Analyze [feature area] architecture.
   Return: design pattern used, how modules connect, data flow, example usage
   (2-3 line snippet). Max 200 words."

   **Agent 3 - Entity discovery:** "Find existing models/entities related to
   [feature]. Return: file paths, key properties, relationships, validation
   rules. Max 150 words."

   **Token optimization**: Agents return summaries only, ~1.2K tokens total vs
   ~5.5K loading full files (78% reduction).

4. **Generate specification**: a. Parse description → identify actors, actions,
   data, constraints b. For unclear aspects:
   - Make informed guesses from context/standards
   - Mark [NEEDS CLARIFICATION: question] ONLY if:
     - Choice significantly impacts scope/UX/security
     - Multiple interpretations exist
     - No reasonable default
   - **MAX 3 clarifications total**
   - Priority: scope > security > UX > technical c. Fill sections per template:
   - User Stories with acceptance criteria
   - Functional Requirements (testable)
   - Success Criteria (measurable, tech-agnostic)
   - Entities (if data involved) d. Document assumptions in spec

5. **Validate specification**: a. Create
   `FEATURE_DIR/checklists/requirements.md`:

   ```markdown
   # Specification Quality: [FEATURE]

   ## Content

   - [ ] No implementation details
   - [ ] Tech-agnostic success criteria
   - [ ] All mandatory sections complete

   ## Requirements

   - [ ] No [NEEDS CLARIFICATION] markers
   - [ ] Requirements testable/unambiguous
   - [ ] Edge cases identified
   - [ ] Dependencies/assumptions listed

   ## Readiness

   - [ ] Acceptance criteria clear
   - [ ] User scenarios cover flows
   - [ ] Scope bounded
   ```

   b. **If validation fails** (excluding clarifications):
   - List failing items
   - Update spec (max 3 iterations)
   - Warn if still failing

   c. **If [NEEDS CLARIFICATION] markers exist**:
   - **Enforce limit**: Keep only 3 most critical
   - Present each as table with options and implications
   - Wait for user responses
   - Update spec with answers
   - Re-validate

6. **Report**:
   - Branch: {BRANCH_NAME}
   - Spec: {SPEC_FILE}
   - Validation status
   - Next: `/speckit.clarify` or `/speckit.plan`

## Guidelines

- **WHAT/WHY**: Focus on user needs and value
- **No HOW**: Avoid tech stack, code structure, APIs
- **Audience**: Business stakeholders, not developers
- **Assumptions**: Document reasonable defaults
- **Limit clarifications**: Max 3, only for critical decisions
- **Success criteria**: Measurable, user-focused, no tech details
