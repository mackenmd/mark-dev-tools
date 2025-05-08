# ---------------------------------------
# Test script for initgit and initgitremote
# ---------------------------------------

Write-Host "`n=== Starting tests for initgit / initgitremote ===`n"

$tests = @(
    @{ Name = "Local - ProjectName only"; Cmd = 'initgit -ProjectName "test-local-1"' },
    @{ Name = "Remote - ProjectName only"; Cmd = 'initgitremote -ProjectName "test-remote-1"' },
    @{ Name = "Remote - ProjectName + RemoteUrl"; Cmd = 'initgitremote -ProjectName "test-remote-2" -RemoteUrl "https://github.com/mackenmd/test-remote-2.git"' },
    @{ Name = "Remote - ProjectPath only"; Cmd = 'initgitremote -ProjectPath "D:\OneDrive\testProjects\test-remote-path-only"' },
    @{ Name = "Remote - ProjectPath + RemoteUrl"; Cmd = 'initgitremote -ProjectPath "D:\OneDrive\testProjects\custom-path" -RemoteUrl "https://github.com/mackenmd/custom-path.git"' },
    @{ Name = "Invalid - missing all"; Cmd = 'initgitremote' }
)

foreach ($test in $tests) {
    Write-Host "`n-- $($test.Name) --"
    try {
        Invoke-Expression $test.Cmd
        Write-Host "✅ Success"
    } catch {
        Write-Warning "❌ Failed: $($_.Exception.Message)"
    }
}

Write-Host "`n=== Tests completed ===`n"
