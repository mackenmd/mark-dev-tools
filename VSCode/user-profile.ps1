# --------------------------------------------------
# Mark's Portable PowerShell Profile (Simplified)
# Location: mark-dev-tools\VSCode\user-profile.ps1
# --------------------------------------------------

Write-Host ""
Write-Host "=== Loading Mark's PowerShell profile ==="

# Alias to the init script
$initScript = "D:\OneDrive\git\mark-dev-tools\PowerShell\Init-GitProject.ps1"

if (Test-Path $initScript) {
    Set-Alias initgit $initScript
    Write-Host "  initgit - Local and optionally remote Git project setup.  initgit --help for usage."
} else {
    Write-Warning "Init script not found at $initScript - initgit not loaded."
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

Write-Host "Profile loaded successfully"
Write-Host ""
