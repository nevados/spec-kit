# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Architecture

**Spec Kit** consists of two main components:

1. **Specify CLI** (`src/specify_cli/`): Python CLI tool that downloads and
   extracts template packages from GitHub releases
2. **Template Artifacts** (`templates/`, `scripts/`, `memory/`): Markdown
   templates, slash commands, and shell scripts that get packaged and
   distributed to user projects

**Not a monorepo**: This repo contains the CLI source code and the template
files. When users run `specify init`, the CLI fetches a pre-packaged ZIP from
GitHub releases and extracts it into their project.

## Development Commands

### Setup

```bash
# Install dependencies
uv sync

# Test CLI locally
uv run specify --help
uv run specify check
```

### Testing Changes Locally

**IMPORTANT**: `uv run specify init` pulls released packages from GitHub, NOT
local changes.

To test local changes:

```bash
# 1. Generate local release packages
./.github/workflows/scripts/create-release-packages.sh v1.0.0

# 2. Copy package to test project
cp -r .genreleases/sdd-claude-package-sh/. <path-to-test-project>/

# 3. Open agent in test project to verify changes
```

### Version Management

**CRITICAL**: Changes to `src/specify_cli/__init__.py` require:

1. Version bump in `pyproject.toml`
2. Entry added to `CHANGELOG.md`

## Template Architecture

### Template Design Patterns

Templates use Claude-specific features (v3.0+):

- **Task tool**: Commands spawn parallel agents for research/analysis
- **Model selection**: Commands specify Haiku (fast) or Sonnet (code-aware)
  based on task complexity
- **Pre-approved commands**: `.claude/settings.json` includes allow-list for
  common git/file operations

#### Command Structure Pattern

Commands in `templates/commands/` follow this structure:

```markdown
1. Read relevant templates/specs
2. Spawn Task agents (Explore/Plan) for research
3. Aggregate results
4. Write output to specs/###-feature/ directory
5. Update CLAUDE.md with feature context
```

### Directory Structure (User Projects)

```text
.claude/
  commands/          # Slash commands installed in user projects
  settings.json      # Allow commands configuration

templates/
  spec-template.md
  plan-template.md
  tasks-template.md
  checklist-template.md
  commands/          # Command implementations
  skills/            # Auto-invokable skills

memory/
  constitution.md    # Project principles

specs/
  ###-feature/       # Feature specifications
    spec.md
    plan.md
    tasks.md
    data-model.md
    contracts/

scripts/
  bash/              # Shell scripts
  powershell/        # PowerShell scripts
```

### Workflow Pattern

Commands follow a phase-based pattern:

1. **constitution** → establish project principles in `memory/constitution.md`
2. **specify** → create `specs/###-feature/spec.md` from user requirements
3. **clarify** → (optional) interactive Q&A to refine spec
4. **plan** → create `plan.md`, `research.md`, `data-model.md`, `contracts/`
5. **tasks** → generate `tasks.md` with ordered, parallelizable task list
6. **analyze** → (optional) cross-artifact consistency validation
7. **implement** → execute tasks from `tasks.md`
8. **review** → (optional) verify implementation matches spec

## Script Patterns

Scripts in `scripts/bash/` (with PowerShell equivalents in
`scripts/powershell/`):

### Common Functions (`common.sh`)

- Path resolution: Find project root, templates, specs directories
- Git operations: Branch detection, status checks
- Feature detection: Determine current feature from branch name or
  SPECIFY_FEATURE env var
- Logging: Consistent output formatting

### Script Responsibilities

- **`create-new-feature.sh`**: Creates feature branch, optionally creates GitHub
  issue, sets up spec directory
- **`check-prerequisites.sh`**: Validates git, templates, required tools
- **`setup-plan.sh`**: Copies plan template to feature directory
- **`update-agent-context.sh`**: Updates project CLAUDE.md with current feature
  context (long, complex - modifies root CLAUDE.md)
- **`gather-review-context.sh`**: Collects git diff and spec files for review

### Script Conventions

- Always source `common.sh` first for shared utilities
- Use `log_info`, `log_error`, `log_success` for output
- Exit with non-zero on errors
- Support both git branch detection and `SPECIFY_FEATURE` env var

## Code Patterns

### Python CLI (`src/specify_cli/__init__.py`)

**Single-file CLI design**:

- `typer` for CLI framework, `rich` for formatted output
- `httpx` + `truststore` for GitHub API with proper SSL verification
- `StepTracker` class for hierarchical progress rendering (similar to Claude
  Code's tree output)
- Cross-platform: Handles Windows/POSIX differences (PowerShell vs bash, path
  separators)

**Key patterns**:

- Download from GitHub releases (not local files)
- Extract ZIP with special handling for nested directories and
  `.vscode/settings.json` merging
- Auto-set execute permissions on `.sh` files (POSIX only)
- Rate limit detection with user-friendly error messages
- Support for `--here` flag (init in current directory) and `--force` (skip
  confirmation)

### Template Structure

Commands in `templates/commands/` are long markdown files with:

- Embedded instructions for reading templates
- Task tool invocations with specific agent types (Explore, Plan, etc.)
- File writing instructions with exact paths
- Script execution commands

Templates in `templates/` are minimal structures:

- `spec-template.md`: User stories, requirements, success criteria
- `plan-template.md`: Stack, structure, research, design phases
- `tasks-template.md`: Phased task breakdown with [P] markers for parallelizable
  tasks
- `checklist-template.md`: Validation checklist format

## Testing Requirements

Before committing/pushing:

1. **ALWAYS run `markdownlint-cli2 '**/\*.md'`before`git push`\*\* - All
   markdown files must pass linting
2. Test with sample project using workflow commands
3. Verify templates render correctly
4. Test both bash and PowerShell script variants if changing scripts
5. Validate GitHub API integration if modifying download logic
6. Test both new project and `--here` (current directory) initialization modes

## GitHub Integration

- Fetches latest release assets from `nevados/spec-kit`
- Rate limit handling with informative error messages
- Supports GitHub token via `--github-token`, `GH_TOKEN`, or `GITHUB_TOKEN` env
  vars
- Uses GraphQL API for GitHub issue type assignment

## Common Development Tasks

### Adding a New Slash Command

1. Create `templates/commands/new-command.md` with command implementation
2. Add command metadata in `templates/.claude/` (if command should be
   registered)
3. Test locally: generate release package and copy to test project
4. Verify command shows up in slash command autocomplete

### Modifying Template Structure

1. Edit template in `templates/*.md` (spec-template, plan-template, etc.)
2. Update any commands in `templates/commands/` that reference the template
3. Generate release package and test full workflow in sample project
4. Consider backward compatibility - users may have existing specs

### Adding Script Functionality

Pattern: Always implement in both bash and PowerShell

1. Edit `scripts/bash/script.sh`
2. Edit `scripts/powershell/script.ps1` with equivalent logic
3. Add shared utilities to `common.sh`/`common.ps1` if needed
4. Test on Linux/macOS (bash) and Windows (PowerShell)
5. Executable permissions auto-handled by CLI

### Modifying CLI Behavior

When changing `src/specify_cli/__init__.py`:

1. Bump version in `pyproject.toml`
2. Add entry to `CHANGELOG.md`
3. Test with `uv run specify init` on new project
4. Test `--here` mode on existing directory
5. Test error cases (rate limiting, network failures, invalid inputs)
