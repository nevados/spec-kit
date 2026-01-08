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

param()

$ErrorActionPreference = "Stop"

# Get script directory and load common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonScript = Join-Path $ScriptDir "common.ps1"

# Initialize variables
$CurrentBranch = $null
$FeatureDir = $null
$FeatureSpec = $null

if (Test-Path $CommonScript) {
    . $CommonScript
    try {
        $paths = Get-FeaturePaths
        $CurrentBranch = $paths.CURRENT_BRANCH
        $FeatureDir = $paths.FEATURE_DIR
        $FeatureSpec = $paths.FEATURE_SPEC
    } catch {
        # Silently continue if paths cannot be determined
    }
}

# Read hook input from stdin (JSON with tool information)
$input = [Console]::In.ReadToEnd()

# Extract tool name from input
$toolName = ""
if ($input -match '"tool_name"\s*:\s*"([^"]*)"') {
    $toolName = $matches[1]
}

# Only validate for Task tool (subagent invocations)
if ($toolName -ne "Task") {
    # Allow all non-Task tools without validation
    Write-Output '{"decision": "allow"}'
    exit 0
}

# Validation checks for spec-kit workflow
$warnings = @()

# Check 1: Verify we can determine current feature
if ([string]::IsNullOrEmpty($CurrentBranch) -or $CurrentBranch -eq "main") {
    $warnings += "Not on a feature branch (current: $($CurrentBranch ?? 'unknown'))"
}

# Check 2: Verify spec directory exists (if we have a feature dir)
if (-not [string]::IsNullOrEmpty($FeatureDir) -and -not (Test-Path $FeatureDir -PathType Container)) {
    $warnings += "Feature directory not found: $FeatureDir"
}

# Check 3: Verify spec.md exists (for spec-kit workflows)
if (-not [string]::IsNullOrEmpty($FeatureSpec) -and (Test-Path $FeatureSpec)) {
    # Spec exists - good
} elseif (-not [string]::IsNullOrEmpty($FeatureDir) -and (Test-Path $FeatureDir -PathType Container)) {
    $warnings += "spec.md not found in $FeatureDir"
}

# Output warnings to stderr
foreach ($warning in $warnings) {
    [Console]::Error.WriteLine("[spec-kit] Warning: $warning")
}

# Always allow - we use warnings to inform, not block
Write-Output '{"decision": "allow"}'
exit 0
