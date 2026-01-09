#!/usr/bin/env bash

# PreToolUse hook for validating spec context before Task tool execution
#
# This hook validates that spec-kit context is properly set up before
# launching subagents. It helps catch configuration issues early.
#
# Hook receives JSON via stdin with tool call information.
# Returns: JSON with decision (allow/deny/ask) and optional reason.
#
# Usage: Called automatically by Claude Code when Task tool is invoked
#        when configured in .claude/settings.json hooks.PreToolUse

set -e

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if common.sh exists before sourcing
if [[ -f "$SCRIPT_DIR/common.sh" ]]; then
    source "$SCRIPT_DIR/common.sh"
    eval $(get_feature_paths 2>/dev/null) || true
fi

# Read hook input from stdin (JSON with tool information)
input=$(cat)

# Extract tool name from input
tool_name=$(echo "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//' || echo "")

# Only validate for Task tool (subagent invocations)
if [[ "$tool_name" != "Task" ]]; then
    # Allow all non-Task tools without validation
    echo '{"decision": "allow"}'
    exit 0
fi

# Validation checks for spec-kit workflow
warnings=()

# Check 1: Verify we can determine current feature
if [[ -z "${CURRENT_BRANCH:-}" ]] || [[ "$CURRENT_BRANCH" == "main" ]]; then
    # Not on a feature branch - this might be intentional
    # Just log, don't block
    warnings+=("Not on a feature branch (current: ${CURRENT_BRANCH:-unknown})")
fi

# Check 2: Verify spec directory exists (if we have a feature dir)
if [[ -n "${FEATURE_DIR:-}" ]] && [[ ! -d "$FEATURE_DIR" ]]; then
    warnings+=("Feature directory not found: $FEATURE_DIR")
fi

# Check 3: Verify spec.md exists (for spec-kit workflows)
if [[ -n "${FEATURE_SPEC:-}" ]] && [[ -f "$FEATURE_SPEC" ]]; then
    # Spec exists - good
    :
elif [[ -n "${FEATURE_DIR:-}" ]] && [[ -d "$FEATURE_DIR" ]]; then
    warnings+=("spec.md not found in $FEATURE_DIR")
fi

# Output result
if [[ ${#warnings[@]} -gt 0 ]]; then
    # Log warnings to stderr (visible in Claude Code output)
    for warning in "${warnings[@]}"; do
        echo "[spec-kit] Warning: $warning" >&2
    done
fi

# Always allow - we use warnings to inform, not block
# This prevents disrupting non-spec-kit workflows
echo '{"decision": "allow"}'
exit 0
