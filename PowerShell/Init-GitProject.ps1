param (
    [string]$ProjectName,
    [string]$ProjectPath = $null,
    [string]$Template = $null,
    [string]$RemoteUrl = $null,
    [switch]$UseRemote = $false,
    [switch]$MakePublic = $false,
    [switch]$TestProject = $false
)

if ($ProjectName -eq "--help" -or $ProjectName -eq "-?") {
    Write-Host ""
    Write-Host "Usage: initgit [-ProjectName] <name> [-Template <name>] [-UseRemote] [-MakePublic] [-TestProject]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -ProjectName     Required if ProjectPath is not specified."
    Write-Host "  -ProjectPath     Optional full path. If not provided, resolved using base path + ProjectName."
    Write-Host "  -Template        Optional template folder name (e.g., 'typescript-basic')"
    Write-Host "  -UseRemote       If present, creates and pushes to GitHub repo."
    Write-Host "  -MakePublic      Used with -UseRemote to make GitHub repo public (default is private)."
    Write-Host "  -TestProject     Uses test folder root instead of production."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  initgit -ProjectName 'local-sandbox'"
    Write-Host "  initgit -ProjectName 'api-ts' -Template 'typescript-basic'"
    Write-Host "  initgit -ProjectName 'live-app' -UseRemote -MakePublic"
    Write-Host "  initgit -ProjectName 'sandbox' -UseRemote -TestProject"
    Write-Host ""
    exit 0
}

# Load base project paths
$PathConfig = "$PSScriptRoot\..\Common\paths.conf"
if (-not (Test-Path $PathConfig)) {
    Write-Error "Missing path config: $PathConfig"
    Write-InitLog "ERROR: Missing path config: $PathConfig"
    exit 1
}

$PathSettings = @{}
foreach ($line in Get-Content $PathConfig | Where-Object { $_ -match '=' }) {
    $parts = $line -split '=', 2
    $PathSettings[$parts[0].Trim()] = $parts[1].Trim()
}

function Write-InitLog {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logPath = Join-Path $PathSettings["LogFolder"] "initgit.log"
    Add-Content -Path $logPath -Value "$timestamp - $Message"
}

Write-InitLog "Started initgit for ProjectName='$ProjectName', ProjectPath='$ProjectPath'"

# Enforce required inputs
if (-not $ProjectName -and -not $ProjectPath) {
    Write-Error "You must specify either -ProjectName or -ProjectPath."
    Write-InitLog "ERROR: You must specify either -ProjectName or -ProjectPath."

    exit 1
}

if (-not (Test-Path $PathSettings["LogFolder"])) {
    New-Item -ItemType Directory -Path $PathSettings["LogFolder"] | Out-Null
}

# Resolve ProjectPath if missing
if (-not $ProjectPath) {
    $basePath = if ($TestProject) {
        $PathSettings["TestBasePath"]
    } else {
        $PathSettings["ProdBasePath"]
    }

    if (-not $basePath) {
        Write-Error "Base path not configured for selected mode (Test/Prod)."
        Write-InitLog "Base path not configured for selected mode (Test/Prod)."

        exit 1
    }

    $ProjectPath = Join-Path $basePath $ProjectName
}

# Resolve ProjectName if only path is given
if (-not $ProjectName) {
    $ProjectName = Split-Path $ProjectPath -Leaf
}

# Load Git identity from Common folder
$ConfigPath = "$PSScriptRoot\..\Common\identity.conf"
if (-not (Test-Path $ConfigPath)) {
    Write-Host "ERROR: Missing config file: $ConfigPath"
    Write-InitLog "ERROR: Missing config file: $ConfigPath"

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

# Apply project template if provided
if ($Template) {
    $templatePath = "D:\OneDrive\git\mark-dev-tools\.templates\$Template"
    if (Test-Path $templatePath) {
        Write-Host "Copying template: $Template"
        Copy-Item -Path "$templatePath\*" -Destination $ProjectPath -Recurse -Force
        git add .
        git commit -m "Apply '$Template' project template"
    } else {
        Write-Warning "Template not found: $templatePath"
    }
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
            Write-InitLog "ERROR: Cannot create remote. ProjectName is required if RemoteUrl is not set."

            exit 1
        }
        $RemoteUrl = "https://github.com/mackenmd/$ProjectName.git"
    }

    $repoCheck = gh repo view mackenmd/$ProjectName 2>$null
    if (-not $repoCheck) {
        # Determine visibility from switch
        $visibility = if ($MakePublic.IsPresent) { "--public" } else { "--private" }

        Write-Host "Creating remote GitHub repo: mackenmd/$ProjectName ($visibility)"
        gh repo create mackenmd/$ProjectName $visibility --source . --remote origin --push
        Write-InitLog "Created GitHub repo: $RemoteUrl"
    } else {
        git remote add origin $RemoteUrl
        git branch -M main
        git push -u origin main
        Write-InitLog "GitHub repo already existed: $RemoteUrl"

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
