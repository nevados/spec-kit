---
description: Identify underspecified areas and resolve with targeted questions (max 5)
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create technical plan for this spec
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## Input

```text
$ARGUMENTS
```

## Execution

1. **Load spec**: Run `{SCRIPT}` for FEATURE_DIR and FEATURE_SPEC paths

2. **Scan for ambiguity** (create internal coverage map):
   - Functional scope & out-of-scope
   - User roles/personas
   - Entities/relationships/lifecycle
   - Data volume/scale
   - Critical user journeys
   - Error/empty/loading states
   - Performance/scalability targets
   - Security/privacy posture
   - External dependencies/failure modes
   - Edge cases/conflict resolution
   - Technical constraints
   - Terminology consistency
   - TODO markers/vague adjectives

   Mark each: Clear / Partial / Missing

3. **Generate question queue** (max 5, prioritized by impact):
   - Only include if materially impacts architecture, data modeling, UX, or
     compliance
   - Ensure balance across categories (don't ask 2 low-impact when high-impact
     unresolved)
   - Each must be answerable via:
     - Multiple-choice (2-5 options), OR
     - Short answer (≤5 words)

4. **Sequential questioning** (ONE at a time):
   - **For multiple-choice**:
     - Analyze options, recommend best based on: best practices, common
       patterns, risk reduction, project goals
     - Format:

       ```markdown
       **Recommended:** Option [X] - <1-2 sentence reasoning>

       | Option | Description               |
       | ------ | ------------------------- |
       | A      | <description>             |
       | B      | <description>             |
       | Short  | Provide custom (≤5 words) |

       Reply with letter (e.g., "A"), "yes"/"recommended" for my suggestion, or
       custom answer.
       ```

   - **For short-answer**:
     - Provide suggested answer with reasoning
     - Format: `**Suggested:** <answer> - <reasoning>`
     - Then:
       `Short answer (≤5 words). Say "yes"/"suggested" to accept, or provide own.`

   - Wait for answer, validate, record in memory
   - If user says "yes"/"recommended"/"suggested", use your suggestion
   - Stop when: all resolved, user signals done, or 5 questions asked

5. **Integrate after EACH answer** (incremental):
   - First answer: Create `## Clarifications` section after overview
   - Append: `- Q: <question> → A: <answer>`
   - Update relevant sections:
     - Functional → Requirements
     - User interaction → User Stories/Actors
     - Data → Entities/Data Model
     - Non-functional → Quality Attributes
     - Edge cases → Edge Cases section
     - Terminology → Normalize across spec
   - Replace contradictory statements
   - **Save spec after each integration** (atomic)

6. **Validate after each write**:
   - One bullet per answer in Clarifications
   - ≤5 questions total
   - No vague placeholders remain
   - No contradictory statements
   - Terminology consistent

7. **Report completion**:
   - Questions asked/answered
   - Updated spec path
   - Sections touched
   - Coverage table: Resolved / Deferred / Clear / Outstanding
   - Recommend: proceed to `/speckit.plan` or re-run if needed

## Rules

- If no critical ambiguities: "No ambiguities worth clarification" → suggest
  proceeding
- Missing spec: instruct `/speckit.specify` first
- Never exceed 5 questions
- Respect early termination ("stop", "done", "proceed")
- User decides: proceed vs fix
