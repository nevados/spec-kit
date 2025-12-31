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

Optional: `--issue <number|URL>` - Use existing GitHub issue instead of creating
new one

Feature description:

```text
$ARGUMENTS
```

## Execution

1. **Handle GitHub issue**:
   - If `--issue` provided: Fetch existing issue details from GitHub
   - If no `--issue`: Create new GitHub issue with:
     - Title: Extract from feature description (first line, max 100 chars)
     - Body: Feature description (high-level, no technical details)
     - Label: "spec"
     - Type: "Enhancement" (via GraphQL)
     - Assigned to: Current user (automatic via `gh`)
   - Extract issue number and title for branch naming

2. **Run setup script** (once only):

   ```bash
   {SCRIPT} --json --issue {issue_number} "Feature description"
   ```

   Script will:
   - Fetch issue title from GitHub if not already fetched
   - Generate branch name: `{issue_number}-{slugified-title}` (e.g.,
     "2011-upgrade-dependencies")
   - Check if branch exists (auto-checkout if yes, create if no)
   - Push new branch to origin (if newly created)
   - Create draft PR linking to issue (if newly created)

   Parse JSON output for BRANCH_NAME, SPEC_FILE, ISSUE_URL, PR_URL

3. **Research codebase patterns** (use Task tool):
   - Model: `haiku` (fast pattern extraction)
   - Agent: `Explore`
   - Prompt: "Find patterns for [feature]. Return: file patterns, architecture,
     naming conventions, data patterns. Max 200 words."

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
   - Issue: #{ISSUE_NUMBER} ({ISSUE_URL})
   - Branch: {BRANCH_NAME}
   - Spec: {SPEC_FILE}
   - PR: {PR_URL} (draft)
   - Validation status
   - Next: `/speckit.clarify` or `/speckit.plan`

## Guidelines

- **WHAT/WHY**: Focus on user needs and value
- **No HOW**: Avoid tech stack, code structure, APIs
- **Audience**: Business stakeholders, not developers
- **Assumptions**: Document reasonable defaults
- **Limit clarifications**: Max 3, only for critical decisions
- **Success criteria**: Measurable, user-focused, no tech details
