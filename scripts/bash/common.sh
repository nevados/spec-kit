#!/usr/bin/env bash
# Common functions and variables for all scripts

# Valid conventional commit types
VALID_COMMIT_TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

# Get repository root, with fallback for non-git repositories
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        # Fall back to script location for non-git repos
        local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        (cd "$script_dir/../../.." && pwd)
    fi
}

# Get current branch, with fallback for non-git repositories
get_current_branch() {
    # First check if SPECIFY_FEATURE environment variable is set
    if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
        echo "$SPECIFY_FEATURE"
        return
    fi

    # Then check git if available
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
        return
    fi

    # For non-git repos, try to find the latest feature directory
    local repo_root=$(get_repo_root)
    local specs_dir="$repo_root/specs"

    if [[ -d "$specs_dir" ]]; then
        # Look for conventional commit style directories (type/description)
        local latest_feature=""
        local latest_mtime=0

        for type_dir in "$specs_dir"/{feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert}; do
            if [[ -d "$type_dir" ]]; then
                for dir in "$type_dir"/*; do
                    if [[ -d "$dir" ]]; then
                        local mtime=$(stat -f %m "$dir" 2>/dev/null || stat -c %Y "$dir" 2>/dev/null || echo "0")
                        if [[ "$mtime" -gt "$latest_mtime" ]]; then
                            latest_mtime=$mtime
                            local type_name=$(basename "$type_dir")
                            local dir_name=$(basename "$dir")
                            latest_feature="$type_name/$dir_name"
                        fi
                    fi
                done
            fi
        done

        if [[ -n "$latest_feature" ]]; then
            echo "$latest_feature"
            return
        fi
    fi

    echo "main"  # Final fallback
}

# Check if we have git available
has_git() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

# Check if branch follows conventional commit naming
check_feature_branch() {
    local branch="$1"
    local has_git_repo="$2"

    # For non-git repos, we can't enforce branch naming but still provide output
    if [[ "$has_git_repo" != "true" ]]; then
        echo "[specify] Warning: Git repository not detected; skipped branch validation" >&2
        return 0
    fi

    # Check for conventional commit style: type/description
    if [[ ! "$branch" =~ ^($VALID_COMMIT_TYPES)/ ]]; then
        echo "ERROR: Not on a feature branch. Current branch: $branch" >&2
        echo "Feature branches should be named like: feat/feature-name or fix/bug-description" >&2
        return 1
    fi

    return 0
}

get_feature_dir() { echo "$1/specs/$2"; }

# Find feature directory by branch name
# Supports conventional commit style branches: type/description
find_feature_dir_by_prefix() {
    local repo_root="$1"
    local branch_name="$2"
    local specs_dir="$repo_root/specs"

    # For conventional commit style branches (type/description), use exact match
    if [[ "$branch_name" =~ ^($VALID_COMMIT_TYPES)/ ]]; then
        echo "$specs_dir/$branch_name"
        return
    fi

    # Fallback to exact match for other branch patterns
    echo "$specs_dir/$branch_name"
}

get_feature_paths() {
    local repo_root=$(get_repo_root)
    local current_branch=$(get_current_branch)
    local has_git_repo="false"

    if has_git; then
        has_git_repo="true"
    fi

    local feature_dir=$(find_feature_dir_by_prefix "$repo_root" "$current_branch")

    cat <<EOF
REPO_ROOT='$repo_root'
CURRENT_BRANCH='$current_branch'
HAS_GIT='$has_git_repo'
FEATURE_DIR='$feature_dir'
FEATURE_SPEC='$feature_dir/spec.md'
IMPL_PLAN='$feature_dir/plan.md'
TASKS='$feature_dir/tasks.md'
RESEARCH='$feature_dir/research.md'
DATA_MODEL='$feature_dir/data-model.md'
QUICKSTART='$feature_dir/quickstart.md'
CONTRACTS_DIR='$feature_dir/contracts'
EOF
}

check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
