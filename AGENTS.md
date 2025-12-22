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

## Claude-Specific Patterns

### Model Selection

**Haiku** (fast, cost-effective):

- Pattern extraction and data mapping
- Simple validation and counting
- Document summaries

**Sonnet** (balanced, code-aware):

- Code understanding and implementation
- Architectural analysis
- Complex planning decisions
- Detailed code review

### Agent Delegation Pattern

Commands use the Task tool for parallel agent execution:

| Command   | Agent Pattern                         |
| --------- | ------------------------------------- |
| specify   | Explore agent for codebase research   |
| clarify   | Direct interaction (no delegation)    |
| plan      | Multiple parallel Explore agents      |
| tasks     | Multiple extraction agents            |
| analyze   | 4 parallel analysis agents            |
| implement | Multiple implementation agents        |
| review    | 4 specialized review agents           |

### Template Design

Templates are minimal structures optimized for AI generation:

- **spec-template.md**: User stories, requirements, success criteria
- **plan-template.md**: Stack, structure, research, design
- **tasks-template.md**: Phased task breakdown with parallelization markers
- **checklist-template.md**: Validation checklist format

### Command Design Pattern

All commands follow consistent structure:

- Use Task tool for parallel agent execution where beneficial
- Specify appropriate model (Haiku vs Sonnet) based on task
- Return focused summaries rather than full outputs
- Write results to structured files in specs directory

## Workflow Phases

```text
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
- Script operations: ls specs/\*, grep, head, cat

### Directory Structure

```text
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

## Quality Patterns

Commands maintain quality through:

- Appropriate model selection (Haiku vs Sonnet) based on task complexity
- Parallel agent execution for independent research/analysis tasks
- Focused extraction and analysis phases
- Validation checkpoints between workflow phases
- Consistent directory structure and file naming
