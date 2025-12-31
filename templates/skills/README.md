# Spec-Kit Skills

This directory contains auto-invokable skills for Claude Code that optimize
spec-driven development workflows.

## Available Skills

### 1. spec-analysis.md

**Auto-invokes when:** User asks to analyze, review, or validate a specification
**Model:** Haiku (fast, cost-effective) **Purpose:** Rapid quality analysis of
spec.md files for completeness, clarity, and testability

### 2. implementation-readiness.md

**Auto-invokes when:** User asks if feature is ready for implementation
**Model:** Haiku (parallel agents) **Purpose:** Validate all prerequisite
artifacts exist and meet quality standards

### 3. codebase-research.md

**Auto-invokes when:** User asks about existing code patterns or architecture
**Model:** Sonnet (code understanding) **Purpose:** Efficiently research
codebase using Explore agents, reducing token usage by ~78%

### 4. spec-to-code-alignment.md

**Auto-invokes when:** User asks if code matches specification **Model:**
Haiku + Sonnet (phased approach) **Purpose:** Validate implementation satisfies
all spec requirements

## How Skills Work

Skills are automatically invoked by Claude Code when trigger patterns match user
input:

```text
User: "Is this spec ready?"
→ Auto-invokes: implementation-readiness.md

User: "How does auth work?"
→ Auto-invokes: codebase-research.md

User: "Does code match spec?"
→ Auto-invokes: spec-to-code-alignment.md
```

## Installation

Skills are automatically installed to `.claude/skills/` when running:

```bash
specify init --ai claude
```

## Token Optimization

All skills use Task tool agent delegation for massive token savings:

| Operation                | Without Skills | With Skills  | Savings |
| ------------------------ | -------------- | ------------ | ------- |
| Codebase research        | 58K tokens     | 1.2K tokens  | 78%     |
| Spec analysis            | 8K tokens      | 1.5K tokens  | 81%     |
| Implementation readiness | 12K tokens     | 3K tokens    | 75%     |
| Spec-to-code alignment   | 58K tokens     | 6-18K tokens | 69-90%  |

## Model Strategy

- **Haiku**: Fast extraction, scoring, simple validation
- **Sonnet**: Code understanding, pattern analysis, architectural review
- **Opus**: Not used in skills (reserved for main conversation orchestration)

## Extending Skills

To add new skills:

1. Create `[skill-name].md` in this directory
2. Define trigger patterns (when to auto-invoke)
3. Specify agent delegation strategy
4. Document model usage and token budget
5. Skills are automatically copied to projects on next `specify init`
