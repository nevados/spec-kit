---
description: Validate cross-artifact consistency (spec, plan, tasks) - read-only analysis
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## Input

```text
$ARGUMENTS
```

## Goal

Identify inconsistencies, gaps, ambiguities across spec.md, plan.md, tasks.md before implementation. **STRICTLY READ-ONLY** - no file modifications.

## Execution

1. **Initialize**: Run `{SCRIPT}` for FEATURE_DIR, AVAILABLE_DOCS. Abort if missing prerequisites.

2. **Load artifacts** (parallel Task agents with haiku):
   - Agent 1: "Extract from spec.md: functional requirements (FR-###), user stories with priorities, edge cases. Return structured list."
   - Agent 2: "Extract from plan.md: architecture decisions, tech stack, data model refs, constraints. Return bulleted list."
   - Agent 3: "Extract from tasks.md: all task IDs with descriptions, phase groupings, file paths. Return table."
   - Agent 4: "Load /memory/constitution.md: return all MUST/SHOULD principles with IDs."

   **Token optimization**: ~70% reduction, parallel execution, focused summaries only.

3. **Correlate** agent outputs:
   - Build requirements inventory (from Agent 1)
   - Build task coverage map (cross-ref Agent 1 FR-### with Agent 3 tasks)
   - Build constitution rule set (from Agent 4)

4. **Detection** (limit 50 findings, aggregate overflow):
   - **Duplication**: Near-duplicate requirements
   - **Ambiguity**: Vague adjectives (fast, scalable, secure), unresolved placeholders
   - **Underspecification**: Requirements missing measurable outcomes, tasks referencing undefined components
   - **Constitution**: Conflicts with MUST principles, missing mandated sections
   - **Coverage Gaps**: Requirements with zero tasks, tasks with no requirement/story
   - **Inconsistency**: Terminology drift, data entity mismatches, contradictory requirements

5. **Severity**:
   - **CRITICAL**: Constitution MUST violation, missing core coverage, blocks baseline functionality
   - **HIGH**: Duplicate/conflicting requirement, ambiguous security/performance, untestable acceptance
   - **MEDIUM**: Terminology drift, missing non-functional coverage, underspecified edge case
   - **LOW**: Style/wording improvements, minor redundancy

6. **Report** (Markdown, no file writes):

   ```markdown
   # Specification Analysis Report

   | ID | Category | Severity | Location | Summary | Recommendation |
   |----|----------|----------|----------|---------|----------------|
   | A1 | Duplication | HIGH | spec.md:L120 | ... | Merge phrasing |

   **Coverage Summary**:
   | Requirement | Has Task? | Task IDs | Notes |

   **Constitution Issues**: [if any]
   **Unmapped Tasks**: [if any]

   **Metrics**:
   - Total Requirements: N
   - Total Tasks: N
   - Coverage %: N%
   - Ambiguity Count: N
   - Critical Issues: N
   ```

7. **Next Actions**:
   - If CRITICAL: Recommend resolving before `/speckit.implement`
   - If LOW/MEDIUM: May proceed with improvements noted
   - Provide specific command suggestions

8. **Offer remediation** (don't auto-apply): "Suggest concrete edits for top N issues?"

## Key Rules

- **NEVER modify files** (read-only)
- **Constitution authority**: Violations are CRITICAL
- **Use examples**: Cite specific instances
- **Report zero issues gracefully**: Emit success report with stats
- **Token-efficient**: Limit findings to 50 rows, summarize overflow
- **Deterministic**: Consistent results on reruns
