param (
    [string]$ProjectName,
    [string]$ProjectPath = $null,
    [string]$RemoteUrl = $null,
    [switch]$UseRemote = $false
)

# Resolve default path if not explicitly provided
if (-not $ProjectPath) {
    if (-not $ProjectName) {
        Write-Host "ERROR: You must specify either -ProjectName or -ProjectPath"
        exit 1
    }
    $ProjectPath = "D:\OneDrive\testProjects\$ProjectName"
}

# Load Git identity from Common folder
$ConfigPath = "$PSScriptRoot\..\Common\identity.conf"
if (-not (Test-Path $ConfigPath)) {
    Write-Host "ERROR: Missing config file: $ConfigPath"
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

# Create and initialize the local repo
if (-not (Test-Path $ProjectPath)) {
    New-Item -ItemType Directory -Path $ProjectPath | Out-Null
}
Set-Location $ProjectPath
git init | Out-Null

# Create README if one doesn't exist
if (-not (Test-Path "$ProjectPath\README.md")) {
    "## $ProjectName" | Out-File "$ProjectPath\README.md"
    git add README.md
    git commit -m "Initial commit with README"
}

# Apply local Git identity
git config user.name "$GitName"
git config user.email "$GitEmail"
git config commit.gpgsign "$GitSign"
git config core.editor "$GitEditor"

# Handle remote setup
if ($UseRemote) {
    if (-not $RemoteUrl) {
        if (-not $ProjectName) {
            Write-Host "ERROR: Cannot create remote. ProjectName is required if RemoteUrl is not set."
            exit 1
        }
        $RemoteUrl = "https://github.com/mackenmd/$ProjectName.git"
    }

    $repoCheck = gh repo view mackenmd/$ProjectName 2>$null
    if (-not $repoCheck) {
        Write-Host "Creating remote GitHub repo: mackenmd/$ProjectName"
        gh repo create mackenmd/$ProjectName --public --source . --remote origin --push
    } else {
        git remote add origin $RemoteUrl
        git branch -M main
        git push -u origin main
    }

    Write-Host "Remote 'origin' set to: $RemoteUrl"
}

Write-Host "Git repo initialized at $ProjectPath"
Write-Host "  user.name   = $GitName"
Write-Host "  user.email  = $GitEmail"
Write-Host "  gpgsign     = $GitSign"
Write-Host "  editor      = $GitEditor"
if ($UseRemote) {
    Write-Host "  Remote GitHub repo created and pushed successfully"
}
