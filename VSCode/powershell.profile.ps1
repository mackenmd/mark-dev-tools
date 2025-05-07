# -----------------------------
# Mark's Portable PowerShell Profile
# -----------------------------
# To activate, add to your $PROFILE:
# . "D:\OneDrive\git\mark-dev-tools\VSCode\powershell.profile.ps1"
# -----------------------------

# Basic init (no remote)
Set-Alias initgit "D:\OneDrive\git\mark-dev-tools\PowerShell\Init-GitProject.ps1"

# Init with automatic remote
function initgitremote {
    param (
        [string]$ProjectName,
        [string]$ProjectPath = $null,
        [string]$RemoteUrl = $null
    )

    & "D:\OneDrive\git\mark-dev-tools\PowerShell\Init-GitProject.ps1" `
        -ProjectName $ProjectName `
        -ProjectPath $ProjectPath `
        -RemoteUrl $RemoteUrl `
        -UseRemote
}


Write-Host "✅ PowerShell profile loaded. Commands available:"
Write-Host "   → initgit       (local-only repo)"
Write-Host "   → initgitremote (adds GitHub remote)"
