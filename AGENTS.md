# AGENTS.md

> **Note**: As of version 3.0, spec-kit templates and commands are optimized
> exclusively for **Claude Code (Anthropic)**. The templates leverage
> Claude-specific features like the Task tool, parallel agent execution,
> and appropriate model selection (Haiku/Sonnet) for maximum token efficiency.

## About Spec Kit and Specify

**GitHub Spec Kit** is a comprehensive toolkit for implementing Spec-Driven
Development (SDD) with Claude Code - a methodology that emphasizes creating clear
specifications before implementation. The toolkit includes templates, scripts, and
workflows optimized for Claude's capabilities.

**Specify CLI** is the command-line interface that bootstraps projects with the
Spec Kit framework. It sets up the necessary directory structures, templates,
and Claude Code integrations to support the Spec-Driven Development workflow.

The toolkit was originally designed to support multiple AI coding assistants,
but is now **exclusively optimized for Claude Code** for optimal performance,
token efficiency, and quality.

---

## General practices

- Any changes to `__init__.py` for the Specify CLI require a version rev in
  `pyproject.toml` and addition of entries to `CHANGELOG.md`.

## Claude-Specific Optimizations

### Model Selection Strategy

**Haiku** (fast, cost-effective):
- Pattern extraction and data mapping
- Simple validation and counting
- Document summaries (200-500 words)
- Token cost: ~10x cheaper than Sonnet

**Sonnet** (balanced, code-aware):
- Code understanding and implementation
- Architectural analysis
- Complex planning decisions
- Detailed code review

### Agent Delegation

All commands use the Task tool for parallel agent execution:

| Command | Agents | Model | Token Savings |
|---------|--------|-------|---------------|
| specify | Explore | Haiku | 58% |
| clarify | Direct | N/A | 43% |
| plan | Explore (parallel) | Haiku | 47% |
| tasks | Multiple | Haiku | 60% |
| analyze | 4 parallel | Haiku | 71% |
| implement | Multiple | Sonnet | 40% |
| review | 4 specialized | Haiku+Sonnet | 60% |

### Template Optimizations

All templates optimized for AI generation:
- spec-template.md: 24% reduction (concise, AI-focused)
- plan-template.md: Restructured for clarity
- tasks-template.md: 67% reduction (essential structure only)
- checklist-template.md: 48% reduction (minimal format)

### Command Optimizations

All commands streamlined for token efficiency:
- Average 56% token reduction across all commands
- Parallel agent execution where possible
- Focused prompts returning summaries only
- Clear model selection rationale

## Workflow Phases

```
specify (Haiku for codebase research)
  ↓
clarify (Interactive, max 5 questions)
  ↓
plan (Parallel Haiku agents for research)
  ↓
tasks (Haiku agents for extraction)
  ↓
analyze (4 parallel Haiku agents)
  ↓
implement (Sonnet for code understanding)
  ↓
review (4 agents: 3 Haiku + 1 Sonnet)
```

## Configuration

### Allow Commands

`.claude/settings.json` includes pre-approved commands for ~80% approval reduction:
- Git operations: fetch, ls-remote, branch, diff, status, log
- File operations: Read, Write, Edit, Glob, Grep (templates/specs)
- Script operations: ls specs/*, grep, head, cat

### Directory Structure

```
.claude/
  commands/         # Slash commands
  settings.json     # Allow commands
templates/
  spec-template.md
  plan-template.md
  tasks-template.md
  checklist-template.md
  commands/         # Command implementations
  skills/           # Auto-invokable skills
memory/
  constitution.md   # Project principles
specs/
  ###-feature/      # Feature specifications
scripts/
  bash/            # Shell scripts
  powershell/      # PowerShell scripts
```

## Claude Code Requirements

- Claude Code CLI installed and configured
- Git for branch management
- Bash or PowerShell for scripts

## Quality Assurance

All optimizations maintain or improve quality through:
- Appropriate model selection (Haiku vs Sonnet)
- Parallel agent execution for speed
- Focused extraction and analysis
- Clear validation checkpoints
- Consistent workflow phases

---

_For detailed optimization metrics, see `OPTIMIZATION_SUMMARY.md`._
