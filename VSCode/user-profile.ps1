# --------------------------------------------------
# Mark's Portable PowerShell Profile (Final Version)
# Location: mark-dev-tools\VSCode\user-profile.ps1
# --------------------------------------------------

Write-Host ""
Write-Host "=== Loading Mark's PowerShell profile ==="

# Set core paths
$toolsPath = "D:\OneDrive\git\mark-dev-tools\PowerShell"
$testProjectsPath = "D:\OneDrive\testProjects"
$initScript = Join-Path $toolsPath "Init-GitProject.ps1"

# Ensure testProjects folder exists
if (-not (Test-Path $testProjectsPath)) {
    Write-Host "Creating missing folder: $testProjectsPath"
    New-Item -ItemType Directory -Path $testProjectsPath | Out-Null
}

# Always define aliases if the init script exists
if (Test-Path $initScript) {
    # Local-only Git init
    Set-Alias initgit $initScript

    # Git init + GitHub remote creation
    function initgitremote {
        param (
            [string]$ProjectName,
            [string]$ProjectPath = $null,
            [string]$RemoteUrl = $null
        )
        & $initScript -ProjectName $ProjectName -ProjectPath $ProjectPath -RemoteUrl $RemoteUrl -UseRemote
    }

    Write-Host "  initgit       → Local-only Git project setup"
    Write-Host "  initgitremote → Git project setup with GitHub remote"
} else {
    Write-Warning "Init script not found at $initScript — initgit/initgitremote not loaded."
}

# Optional: Per-machine logic
switch ($env:COMPUTERNAME) {
    "MARK-DESKTOP" {
        Write-Host "  Profile: MARK-DESKTOP loaded"
    }
    "MARK-LAPTOP" {
        Write-Host "  Profile: MARK-LAPTOP loaded"
    }
}

Write-Host "Profile loaded successfully."
Write-Host ""
