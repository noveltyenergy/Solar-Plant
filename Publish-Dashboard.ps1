param([switch]$Watch)
$ErrorActionPreference = 'Stop'
$repoPath = $PSScriptRoot
$dashboardFile = 'NEL_Energy_Flow_Dashboard_v13.html'
$dashboardPath = Join-Path $repoPath $dashboardFile
$env:GIT_TERMINAL_PROMPT = '0'

function Invoke-RepoGit {
    param([string[]]$GitArgs)
    & git -c "safe.directory=$($repoPath.Replace('\','/'))" -C $repoPath @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "Git failed ($LASTEXITCODE): $($GitArgs[0])" }
}

function Publish-Dashboard {
    $status = Invoke-RepoGit -GitArgs @('status','--porcelain','--',$dashboardFile)
    if ($status) {
        Invoke-RepoGit -GitArgs @('add','--',$dashboardFile)
        Invoke-RepoGit -GitArgs @('commit','--only','-m',('Update dashboard ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),'--',$dashboardFile)
    }
    # Also retries an earlier commit whose push failed.
    Invoke-RepoGit -GitArgs @('push','origin','main')
    Write-Host "$(Get-Date -Format s) Dashboard pushed. GitHub Pages will deploy automatically."
}

if (-not $Watch) { Publish-Dashboard; exit }

$mutex = New-Object System.Threading.Mutex($false, 'Local\NEL-Solar-Plant-Dashboard-Publisher')
$hasMutex = $false
try {
    try { $hasMutex = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $hasMutex = $true }
    if (-not $hasMutex) { Write-Host 'A dashboard publisher is already running.'; exit }
    Write-Host "Watching $dashboardPath. Only this HTML file is automatically committed and pushed."
    $publishedHash = ''
    $pendingHash = ''
    $stableSince = Get-Date
    $retryAfter = Get-Date
    while ($true) {
        try {
            $currentHash = (Get-FileHash -LiteralPath $dashboardPath -Algorithm SHA256).Hash
            if ($currentHash -ne $pendingHash) { $pendingHash = $currentHash; $stableSince = Get-Date }
            if ($pendingHash -ne $publishedHash -and ((Get-Date) - $stableSince).TotalSeconds -ge 3 -and (Get-Date) -ge $retryAfter) {
                # A save during publication is noticed and published on the next iteration.
                $attemptHash = $pendingHash
                Publish-Dashboard
                $publishedHash = $attemptHash
            }
        } catch {
            Write-Warning "$(Get-Date -Format s) $($_.Exception.Message). Will retry in 30 seconds."
            $retryAfter = (Get-Date).AddSeconds(30)
        }
        Start-Sleep -Seconds 2
    }
} finally {
    if ($hasMutex) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
