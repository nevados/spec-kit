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

```text
$ARGUMENTS
```

## Execution

1. **Generate branch name** (2-4 words, action-noun format):
   - Extract keywords from feature description
   - Preserve technical terms (OAuth2, API, JWT)
   - Examples: "user-auth", "oauth2-api-integration", "analytics-dashboard"

2. **Check existing branches**:
   ```bash
   git fetch --all --prune
   # Find highest N for short-name across:
   # - Remote: git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'
   # - Local: git branch | grep -E '^[* ]*[0-9]+-<short-name>$'
   # - Specs: ls specs/[0-9]+-<short-name> 2>/dev/null
   # Use N+1 for new branch, or 1 if none exist
   ```

3. **Run setup script** (once only):
   ```bash
   {SCRIPT} --json --number N+1 --short-name "name" "Feature description"
   ```
   Parse JSON output for BRANCH_NAME and SPEC_FILE paths.

4. **Research codebase patterns** (use Task tool):
   - Model: `haiku` (fast pattern extraction)
   - Agent: `Explore`
   - Prompt: "Find patterns for [feature]. Return: file patterns, architecture, naming conventions, data patterns. Max 200 words."

5. **Generate specification**:
   a. Parse description → identify actors, actions, data, constraints
   b. For unclear aspects:
      - Make informed guesses from context/standards
      - Mark [NEEDS CLARIFICATION: question] ONLY if:
        * Choice significantly impacts scope/UX/security
        * Multiple interpretations exist
        * No reasonable default
      - **MAX 3 clarifications total**
      - Priority: scope > security > UX > technical
   c. Fill sections per template:
      - User Stories with acceptance criteria
      - Functional Requirements (testable)
      - Success Criteria (measurable, tech-agnostic)
      - Entities (if data involved)
   d. Document assumptions in spec

6. **Validate specification**:
   a. Create `FEATURE_DIR/checklists/requirements.md`:
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

7. **Report**: Branch name, spec path, validation status, readiness for `/speckit.clarify` or `/speckit.plan`

## Guidelines

- **WHAT/WHY**: Focus on user needs and value
- **No HOW**: Avoid tech stack, code structure, APIs
- **Audience**: Business stakeholders, not developers
- **Assumptions**: Document reasonable defaults
- **Limit clarifications**: Max 3, only for critical decisions
- **Success criteria**: Measurable, user-focused, no tech details
