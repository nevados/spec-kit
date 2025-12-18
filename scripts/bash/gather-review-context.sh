#!/usr/bin/env bash
# Gather review context for /speckit.review command
#
# This script collects:
# - Feature directory paths (from common.sh)
# - Git diff statistics (files changed since branch creation)
# - Task completion status (from tasks.md)
# - Available artifacts (spec, plan, tasks, etc.)
#
# Usage: ./gather-review-context.sh --json
#
# Output: JSON with FEATURE_DIR, FEATURE_SPEC, IMPL_PLAN, TASKS,
#         GIT_DIFF_FILES (array), TOTAL_TASKS, COMPLETED_TASKS

set -e

# Parse arguments
JSON_MODE=false
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: gather-review-context.sh [--json]"
            echo "Gather context for implementation review"
            exit 0
            ;;
    esac
done

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get feature paths
eval $(get_feature_paths)
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# Validate required files exist
if [[ ! -f "$FEATURE_SPEC" ]]; then
    echo "ERROR: spec.md not found. Run /speckit.specify first." >&2
    exit 1
fi

if [[ ! -f "$IMPL_PLAN" ]]; then
    echo "ERROR: plan.md not found. Run /speckit.plan first." >&2
    exit 1
fi

if [[ ! -f "$TASKS" ]]; then
    echo "ERROR: tasks.md not found. Run /speckit.tasks first." >&2
    exit 1
fi

# Gather git diff information (files changed)
diff_files=()
if [[ "$HAS_GIT" == "true" ]]; then
    # Get base branch (typically main/master)
    base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    # Get list of changed files (exclude specs/ directory)
    while IFS= read -r file; do
        if [[ ! "$file" =~ ^specs/ && -n "$file" ]]; then
            diff_files+=("$file")
        fi
    done < <(git diff --name-only "$base_branch"...HEAD 2>/dev/null || echo "")
fi

# Calculate task completion from tasks.md
total_tasks=0
completed_tasks=0
if [[ -f "$TASKS" ]]; then
    # Count total tasks (lines with - [ ] or - [X] or - [x])
    total_tasks=$(grep -cE '^\s*-\s*\[([ Xx])\]' "$TASKS" || echo "0")
    # Count completed tasks (lines with - [X] or - [x])
    completed_tasks=$(grep -cE '^\s*-\s*\[[Xx]\]' "$TASKS" || echo "0")
fi

# Output results
if $JSON_MODE; then
    # Build JSON array of changed files
    if [[ ${#diff_files[@]} -eq 0 ]]; then
        json_files="[]"
    else
        json_files=$(printf '"%s",' "${diff_files[@]}")
        json_files="[${json_files%,}]"
    fi

    printf '{"REPO_ROOT":"%s","FEATURE_DIR":"%s","FEATURE_SPEC":"%s","IMPL_PLAN":"%s","TASKS":"%s","GIT_DIFF_FILES":%s,"TOTAL_TASKS":%d,"COMPLETED_TASKS":%d}\n' \
        "$REPO_ROOT" "$FEATURE_DIR" "$FEATURE_SPEC" "$IMPL_PLAN" "$TASKS" "$json_files" "$total_tasks" "$completed_tasks"
else
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "FEATURE_SPEC: $FEATURE_SPEC"
    echo "IMPL_PLAN: $IMPL_PLAN"
    echo "TASKS: $TASKS"
    echo "Changed files: ${#diff_files[@]}"
    echo "Task completion: $completed_tasks/$total_tasks"
fi
