# Gather review context for /speckit.review command
#
# This script collects:
# - Feature directory paths
# - Git diff statistics (files changed since branch creation)
# - Task completion status (from tasks.md)
# - Available artifacts (spec, plan, tasks, etc.)
#
# Usage: ./gather-review-context.ps1 [-Json]
#
# Output: JSON with FEATURE_DIR, FEATURE_SPEC, IMPL_PLAN, TASKS,
#         GIT_DIFF_FILES (array), TOTAL_TASKS, COMPLETED_TASKS

param(
    [switch]$Json,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: gather-review-context.ps1 [-Json]"
    Write-Host "Gather context for implementation review"
    exit 0
}

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common.ps1"

# Get feature paths
$paths = Get-FeaturePaths
$currentBranch = $paths.CURRENT_BRANCH
$hasGit = $paths.HAS_GIT

# Check feature branch
if (-not (Test-FeatureBranch -Branch $currentBranch -HasGit $hasGit)) {
    exit 1
}

# Validate required files exist
if (-not (Test-Path $paths.FEATURE_SPEC)) {
    Write-Error "ERROR: spec.md not found. Run /speckit.specify first."
    exit 1
}

if (-not (Test-Path $paths.IMPL_PLAN)) {
    Write-Error "ERROR: plan.md not found. Run /speckit.plan first."
    exit 1
}

if (-not (Test-Path $paths.TASKS)) {
    Write-Error "ERROR: tasks.md not found. Run /speckit.tasks first."
    exit 1
}

# Gather git diff information (files changed)
$diffFiles = @()
if ($hasGit -eq "true") {
    try {
        # Get base branch (typically main/master)
        $baseBranch = (git symbolic-ref refs/remotes/origin/HEAD 2>$null) -replace '^refs/remotes/origin/', ''
        if (-not $baseBranch) { $baseBranch = "main" }

        # Get list of changed files (exclude specs/ directory)
        $allFiles = git diff --name-only "$baseBranch...HEAD" 2>$null
        if ($allFiles) {
            $diffFiles = $allFiles | Where-Object { $_ -notmatch '^specs/' -and $_ }
        }
    } catch {
        # Git operations failed, continue with empty diff
    }
}

# Calculate task completion from tasks.md
$totalTasks = 0
$completedTasks = 0
if (Test-Path $paths.TASKS) {
    $taskContent = Get-Content $paths.TASKS -Raw
    # Count total tasks (lines with - [ ] or - [X] or - [x])
    $totalTasks = ([regex]::Matches($taskContent, '^\s*-\s*\[([ Xx])\]', 'Multiline')).Count
    # Count completed tasks (lines with - [X] or - [x])
    $completedTasks = ([regex]::Matches($taskContent, '^\s*-\s*\[[Xx]\]', 'Multiline')).Count
}

# Output results
if ($Json) {
    $output = @{
        REPO_ROOT = $paths.REPO_ROOT
        FEATURE_DIR = $paths.FEATURE_DIR
        FEATURE_SPEC = $paths.FEATURE_SPEC
        IMPL_PLAN = $paths.IMPL_PLAN
        TASKS = $paths.TASKS
        GIT_DIFF_FILES = $diffFiles
        TOTAL_TASKS = $totalTasks
        COMPLETED_TASKS = $completedTasks
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Host "FEATURE_DIR: $($paths.FEATURE_DIR)"
    Write-Host "FEATURE_SPEC: $($paths.FEATURE_SPEC)"
    Write-Host "IMPL_PLAN: $($paths.IMPL_PLAN)"
    Write-Host "TASKS: $($paths.TASKS)"
    Write-Host "Changed files: $($diffFiles.Count)"
    Write-Host "Task completion: $completedTasks/$totalTasks"
}
