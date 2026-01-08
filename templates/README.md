# Spec-Kit Templates

This directory contains templates, commands, agents, and skills for spec-driven
development with Claude Code.

## Directory Structure

```text
templates/
├── .claude/
│   ├── agents/           # Specialized subagents
│   ├── skills/           # Reusable capability modules
│   └── settings.json     # Hooks and permissions config
├── commands/             # Slash command definitions
├── spec-template.md      # Feature specification template
├── plan-template.md      # Technical plan template
├── tasks-template.md     # Task breakdown template
└── checklist-template.md # Validation checklist template
```

## Claude Code 2.1.x Features

Spec-Kit leverages these Claude Code 2.1.x features for improved workflow:

### Hooks

Hooks are configured in `.claude/settings.json` and execute at specific points
in the Claude Code lifecycle:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "scripts/bash/validate-spec-context.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "scripts/bash/update-agent-context.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "scripts/bash/workflow-summary.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook Types:**

- `PreToolUse`: Runs before tool execution. Can validate, warn, or block.
- `PostToolUse`: Runs after tool completion. Used for context updates.
- `Stop`: Runs when main agent completes. Shows workflow summary.

**Spec-Kit Hooks:**

| Hook                | Script                     | Purpose                                   |
| ------------------- | -------------------------- | ----------------------------------------- |
| PreToolUse (Task)   | `validate-spec-context.sh` | Validates spec context before subagents   |
| PostToolUse (Write) | `update-agent-context.sh`  | Updates agent context files automatically |
| Stop                | `workflow-summary.sh`      | Shows feature progress and next steps     |

### Skills

Skills are reusable capability modules that agents can reference. Each skill
lives in `.claude/skills/<skill-name>/SKILL.md`.

**Available Skills:**

| Skill                   | Description                                       |
| ----------------------- | ------------------------------------------------- |
| `spec-validation`       | Validates specification quality and completeness  |
| `requirements-analysis` | Extracts and analyzes requirements from specs     |
| `drift-detection`       | Detects implementation drift from spec            |
| `conflict-detection`    | Detects conflicts between multiple specs          |
| `effort-scoring`        | Scores task effort for planning                   |
| `test-scaffolding`      | Generates test scaffolds from acceptance criteria |

**Skill Frontmatter:**

```yaml
---
name: spec-validation
description: Validates specification quality and completeness
allowed-tools: Read, Grep, Glob
---
```

**Agents Reference Skills:**

Agents declare which skills they use in their frontmatter:

```yaml
---
name: spec-quality-gate
description: Analyze spec quality and flag issues before planning
model: haiku
tools: Read, Grep, Glob
skills: spec-validation, requirements-analysis
---
```

### Agent Disabling

Disable specific agents using `permissions.deny` in settings.json:

```json
{
  "permissions": {
    "deny": ["Task(cross-spec-conflict)", "Task(effort-scorer)"]
  }
}
```

**Use Cases:**

- Single-spec projects: Disable `cross-spec-conflict` detection
- Quick iterations: Disable `effort-scorer` for rapid prototyping
- Focused workflows: Enable only needed agents

**CLI Alternative:**

```bash
claude --disallowedTools "Task(cross-spec-conflict)"
```

## Agents

Agents are specialized subagents for specific analysis tasks:

| Agent                 | Model  | Purpose                         |
| --------------------- | ------ | ------------------------------- |
| `spec-quality-gate`   | haiku  | Score spec quality, flag issues |
| `criteria-extractor`  | haiku  | Extract acceptance criteria     |
| `cross-spec-conflict` | haiku  | Detect conflicts between specs  |
| `effort-scorer`       | haiku  | Score task complexity           |
| `spec-drift-check`    | haiku  | Detect implementation drift     |
| `test-scaffold`       | sonnet | Generate test scaffolds         |

**Agent Frontmatter:**

```yaml
---
name: spec-quality-gate
description: Analyze spec quality and flag issues before planning
model: haiku
tools: Read, Grep, Glob
skills: spec-validation, requirements-analysis
---
```

## Commands

Slash commands implement the spec-kit workflow:

| Command                  | Description                         |
| ------------------------ | ----------------------------------- |
| `/speckit.specify`       | Create feature specification        |
| `/speckit.clarify`       | Resolve ambiguous requirements      |
| `/speckit.plan`          | Generate technical plan             |
| `/speckit.tasks`         | Generate task breakdown             |
| `/speckit.analyze`       | Validate cross-artifact consistency |
| `/speckit.implement`     | Execute implementation              |
| `/speckit.review`        | Verify implementation matches spec  |
| `/speckit.checklist`     | Generate validation checklist       |
| `/speckit.constitution`  | Create project principles           |
| `/speckit.testgen`       | Generate test scaffolds             |
| `/speckit.taskstoissues` | Convert tasks to GitHub issues      |

## Incremental Output

For long-running operations, agents provide incremental output using the
Task tool's async capabilities:

```typescript
// Commands can launch background agents
Task({
  subagent_type: 'Plan',
  run_in_background: true,
  prompt: '...'
})
```

**Monitoring Background Agents:**

- Use `/tasks` to list running tasks
- Use `TaskOutput` tool to check progress
- Background agents write to output files you can read

## Customization

### Adding Custom Skills

1. Create directory: `.claude/skills/<skill-name>/`
2. Add `SKILL.md` with frontmatter and instructions
3. Reference from agents via `skills:` field

### Adding Custom Agents

1. Create file: `.claude/agents/<agent-name>.md`
2. Add frontmatter: name, description, model, tools, skills
3. Add agent instructions as markdown

### Modifying Hooks

Edit `.claude/settings.json` to add/remove hooks:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "YourTool",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh"
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting

### Hooks Not Running

1. Check `.claude/settings.json` syntax (valid JSON)
2. Verify script paths are correct
3. Ensure scripts are executable (`chmod +x`)
4. Check matcher patterns match tool names exactly

### Agent Not Found

1. Verify agent file exists in `.claude/agents/`
2. Check frontmatter `name:` matches invocation
3. Ensure file has `.md` extension

### Skills Not Loading

1. Verify skill directory structure: `.claude/skills/<name>/SKILL.md`
2. Check skill name in agent's `skills:` field matches directory name
3. Ensure SKILL.md has valid frontmatter
