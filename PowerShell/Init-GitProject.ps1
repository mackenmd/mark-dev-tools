param (
    [string]$ProjectName,
    [string]$ProjectPath = $null,
    [string]$RemoteUrl = $null
)

# Resolve default path if not explicitly provided
if (-not $ProjectPath) {
    if (-not $ProjectName) {
        Write-Host "❌ You must specify either -ProjectName or -ProjectPath"
        exit 1
    }
    $ProjectPath = "D:\OneDrive\testProjects\$ProjectName"
}

# Load Git identity from Common folder
$ConfigPath = "$PSScriptRoot\..\Common\identity.conf"
if (-not (Test-Path $ConfigPath)) {
    Write-Host "❌ Missing config: $ConfigPath"
    exit 1
}

$Config = Get-Content $ConfigPath | Where-Object { $_ -match '=' }
$Settings = @{}
foreach ($line in $Config) {
    $parts = $line -split '=', 2
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()
    $Settings[$key] = $value
}

$GitName   = $Settings["name"]
$GitEmail  = $Settings["email"]
$GitSign   = $Settings["sign"]
$GitEditor = $Settings["editor"]

# Create and initialize the repo
if (-not (Test-Path $ProjectPath)) {
    New-Item -ItemType Directory -Path $ProjectPath | Out-Null
}
Set-Location $ProjectPath
git init | Out-Null

if ($RemoteUrl) {
    git remote add origin $RemoteUrl
}

git config user.name "$GitName"
git config user.email "$GitEmail"
git config commit.gpgsign "$GitSign"
git config core.editor "$GitEditor"

Write-Host "✅ Git repo initialized at $ProjectPath"
Write-Host "   → user.name   = $GitName"
Write-Host "   → user.email  = $GitEmail"
Write-Host "   → gpgsign     = $GitSign"
Write-Host "   → editor      = $GitEditor"
