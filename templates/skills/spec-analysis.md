# Spec Analysis Skill

**Auto-invoke when:** User asks to analyze, review, or validate a specification document.

**Trigger patterns:**

- "Analyze this spec"
- "Review the specification"
- "Check if the spec is complete"
- "Validate the requirements"
- "Is this spec ready for implementation?"

## Purpose

Perform rapid quality analysis of spec.md files to identify gaps, ambiguities, and completeness issues before planning or implementation begins.

## Capabilities

1. **Completeness Check**
   - Verify all mandatory sections present (User Stories, Requirements, Success Criteria)
   - Check that user stories have priorities (P1, P2, P3)
   - Validate acceptance criteria use Given/When/Then format
   - Confirm edge cases are documented

2. **Clarity Analysis**
   - Flag vague adjectives ("robust", "fast", "scalable") without metrics
   - Identify ambiguous requirements lacking concrete criteria
   - Detect contradictions or conflicting requirements

3. **Testability Validation**
   - Ensure each requirement is measurable
   - Verify user stories are independently testable
   - Check that success criteria are objective

## Execution Strategy

**Use Haiku agent for fast analysis:**

```text
Task: "Analyze spec.md for completeness, clarity, and testability.
Return:
- Completeness score (1-10)
- Missing sections (list)
- Ambiguous requirements (with line numbers)
- Untestable stories (with reasoning)
Max 400 words."
```

## Output Format

```markdown
# Spec Analysis Results

**Overall Score**: 8/10
**Status**: Ready with minor improvements

## Completeness (9/10)
✓ All mandatory sections present
✓ User stories prioritized
✗ Edge cases section empty

## Clarity (7/10)
⚠ 3 vague requirements found:
  - Line 45: "System must be fast" (no latency target)
  - Line 67: "Intuitive UI" (no usability criteria)
  - Line 89: "Scalable architecture" (no scale target)

## Testability (8/10)
✓ Most stories independently testable
⚠ US3 depends on US1 completion

## Recommendations
1. Add latency targets for "fast" requirement
2. Define edge cases for error scenarios
3. Break US3 into independent stories
```

## Model Usage

- **Haiku** for extraction and scoring (fast, cost-effective)
- **Sonnet** only if deep requirement analysis needed
