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

param()

$ErrorActionPreference = "Stop"

# Get script directory and load common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonScript = Join-Path $ScriptDir "common.ps1"

# Initialize variables
$CurrentBranch = $null
$FeatureDir = $null
$FeatureSpec = $null
$ImplPlan = $null
$Tasks = $null
$Research = $null
$DataModel = $null
$Quickstart = $null
$ContractsDir = $null

if (Test-Path $CommonScript) {
    . $CommonScript
    try {
        $paths = Get-FeaturePaths
        $CurrentBranch = $paths.CURRENT_BRANCH
        $FeatureDir = $paths.FEATURE_DIR
        $FeatureSpec = $paths.FEATURE_SPEC
        $ImplPlan = $paths.IMPL_PLAN
        $Tasks = $paths.TASKS
        $Research = $paths.RESEARCH
        $DataModel = $paths.DATA_MODEL
        $Quickstart = $paths.QUICKSTART
        $ContractsDir = $paths.CONTRACTS_DIR
    } catch {
        # Silently continue
    }
}

# Read hook input from stdin
$input = [Console]::In.ReadToEnd()

# Only output summary if we're in a spec-kit context
if ([string]::IsNullOrEmpty($FeatureDir) -or -not (Test-Path $FeatureDir -PathType Container)) {
    exit 0
}

# Helper function to check artifact
function Check-Artifact {
    param($Path, $Name)
    if (Test-Path $Path) {
        $lines = (Get-Content $Path -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
        [Console]::Error.WriteLine("  ✓ $Name ($lines lines)")
    } else {
        [Console]::Error.WriteLine("  ○ $Name (not created)")
    }
}

# Generate summary
[Console]::Error.WriteLine("")
[Console]::Error.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
[Console]::Error.WriteLine("Spec-Kit Workflow Summary")
[Console]::Error.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

# Feature info
[Console]::Error.WriteLine("")
[Console]::Error.WriteLine("Feature: $($CurrentBranch ?? 'unknown')")
[Console]::Error.WriteLine("Directory: $FeatureDir")

# Artifact status
[Console]::Error.WriteLine("")
[Console]::Error.WriteLine("Artifacts:")

Check-Artifact $FeatureSpec "spec.md"
Check-Artifact $ImplPlan "plan.md"
Check-Artifact $Tasks "tasks.md"
Check-Artifact $Research "research.md"
Check-Artifact $DataModel "data-model.md"
Check-Artifact $Quickstart "quickstart.md"

# Contracts directory
if (Test-Path $ContractsDir -PathType Container) {
    $contractCount = (Get-ChildItem $ContractsDir -Filter "*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
    [Console]::Error.WriteLine("  ✓ contracts/ ($contractCount files)")
} else {
    [Console]::Error.WriteLine("  ○ contracts/ (not created)")
}

# Checklists
$checklistsDir = Join-Path $FeatureDir "checklists"
if (Test-Path $checklistsDir -PathType Container) {
    $checklistCount = (Get-ChildItem $checklistsDir -Filter "*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
    [Console]::Error.WriteLine("  ✓ checklists/ ($checklistCount files)")
}

# Tasks progress (if tasks.md exists)
if (Test-Path $Tasks) {
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("Task Progress:")
    $content = Get-Content $Tasks -Raw -ErrorAction SilentlyContinue
    $totalTasks = ([regex]::Matches($content, '^\s*- \[', 'Multiline')).Count
    $completedTasks = ([regex]::Matches($content, '^\s*- \[x\]', 'Multiline')).Count
    $pendingTasks = $totalTasks - $completedTasks
    [Console]::Error.WriteLine("  Completed: $completedTasks / $totalTasks")
    if ($pendingTasks -gt 0) {
        [Console]::Error.WriteLine("  Remaining: $pendingTasks tasks")
    }
}

# Suggested next steps
[Console]::Error.WriteLine("")
[Console]::Error.WriteLine("Next Steps:")

if (-not (Test-Path $FeatureSpec)) {
    [Console]::Error.WriteLine("  → Run /speckit.specify to create specification")
} elseif (-not (Test-Path $ImplPlan)) {
    [Console]::Error.WriteLine("  → Run /speckit.plan to create technical plan")
} elseif (-not (Test-Path $Tasks)) {
    [Console]::Error.WriteLine("  → Run /speckit.tasks to generate task breakdown")
} else {
    $content = Get-Content $Tasks -Raw -ErrorAction SilentlyContinue
    $pending = ([regex]::Matches($content, '^\s*- \[ \]', 'Multiline')).Count
    if ($pending -gt 0) {
        [Console]::Error.WriteLine("  → Run /speckit.implement to continue implementation")
    } else {
        [Console]::Error.WriteLine("  → Run /speckit.review to verify implementation")
    }
}

[Console]::Error.WriteLine("")
[Console]::Error.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

exit 0
