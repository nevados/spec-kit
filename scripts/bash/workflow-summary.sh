#!/usr/bin/env bash

# Stop hook for generating workflow summary when agent finishes
#
# This hook provides a summary of the spec-kit workflow state when
# Claude Code's main agent completes. Useful for tracking progress
# and identifying next steps.
#
# Hook receives JSON via stdin with session information.
# Output goes to stderr to be visible in Claude Code.
#
# Usage: Called automatically by Claude Code at Stop event
#        when configured in .claude/settings.json hooks.Stop

set -e

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if common.sh exists before sourcing
if [[ -f "$SCRIPT_DIR/common.sh" ]]; then
    source "$SCRIPT_DIR/common.sh"
    eval $(get_feature_paths 2>/dev/null) || true
fi

# Read hook input from stdin
input=$(cat)

# Only output summary if we're in a spec-kit context
if [[ -z "${FEATURE_DIR:-}" ]] || [[ ! -d "${FEATURE_DIR:-/nonexistent}" ]]; then
    # Not in a spec-kit feature context - skip summary
    exit 0
fi

# Generate summary
echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "Spec-Kit Workflow Summary" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

# Feature info
echo "" >&2
echo "Feature: ${CURRENT_BRANCH:-unknown}" >&2
echo "Directory: $FEATURE_DIR" >&2

# Artifact status
echo "" >&2
echo "Artifacts:" >&2

check_artifact() {
    local path="$1"
    local name="$2"
    if [[ -f "$path" ]]; then
        local lines=$(wc -l < "$path" 2>/dev/null || echo "0")
        echo "  ✓ $name ($lines lines)" >&2
    else
        echo "  ○ $name (not created)" >&2
    fi
}

check_artifact "${FEATURE_SPEC:-}" "spec.md"
check_artifact "${IMPL_PLAN:-}" "plan.md"
check_artifact "${TASKS:-}" "tasks.md"
check_artifact "${RESEARCH:-}" "research.md"
check_artifact "${DATA_MODEL:-}" "data-model.md"
check_artifact "${QUICKSTART:-}" "quickstart.md"

# Contracts directory
if [[ -d "${CONTRACTS_DIR:-/nonexistent}" ]]; then
    contract_count=$(find "$CONTRACTS_DIR" -type f -name "*.md" 2>/dev/null | wc -l || echo "0")
    echo "  ✓ contracts/ ($contract_count files)" >&2
else
    echo "  ○ contracts/ (not created)" >&2
fi

# Checklists
if [[ -d "$FEATURE_DIR/checklists" ]]; then
    checklist_count=$(find "$FEATURE_DIR/checklists" -type f -name "*.md" 2>/dev/null | wc -l || echo "0")
    echo "  ✓ checklists/ ($checklist_count files)" >&2
fi

# Tasks progress (if tasks.md exists)
if [[ -f "${TASKS:-/nonexistent}" ]]; then
    echo "" >&2
    echo "Task Progress:" >&2
    total_tasks=$(grep -c "^\s*- \[" "$TASKS" 2>/dev/null || echo "0")
    completed_tasks=$(grep -c "^\s*- \[x\]" "$TASKS" 2>/dev/null || echo "0")
    pending_tasks=$((total_tasks - completed_tasks))
    echo "  Completed: $completed_tasks / $total_tasks" >&2
    if [[ $pending_tasks -gt 0 ]]; then
        echo "  Remaining: $pending_tasks tasks" >&2
    fi
fi

# Suggested next steps
echo "" >&2
echo "Next Steps:" >&2

if [[ ! -f "${FEATURE_SPEC:-/nonexistent}" ]]; then
    echo "  → Run /speckit.specify to create specification" >&2
elif [[ ! -f "${IMPL_PLAN:-/nonexistent}" ]]; then
    echo "  → Run /speckit.plan to create technical plan" >&2
elif [[ ! -f "${TASKS:-/nonexistent}" ]]; then
    echo "  → Run /speckit.tasks to generate task breakdown" >&2
else
    pending=$(grep -c "^\s*- \[ \]" "${TASKS:-/nonexistent}" 2>/dev/null || echo "0")
    if [[ $pending -gt 0 ]]; then
        echo "  → Run /speckit.implement to continue implementation" >&2
    else
        echo "  → Run /speckit.review to verify implementation" >&2
    fi
fi

echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

exit 0
