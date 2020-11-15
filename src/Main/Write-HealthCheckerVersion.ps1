Function Write-HealthCheckerVersion {
    
    $currentVersion = Test-ScriptVersion -ApiUri "api.github.com" -RepoOwner "dpaulson45" `
        -RepoName "HealthChecker" `
        -CurrentVersion $healthCheckerVersion `
        -DaysOldLimit 90 `
        -CatchActionFunction ${Function:Invoke-CatchActions}

    $Script:DisplayedScriptVersionAlready = $true

    if($currentVersion)
    {
        Write-Green("Exchange Health Checker version {0}" -f $healthCheckerVersion)
    }
    else 
    {
        Write-Yellow("Exchange Health Checker version {0}. This script is probably outdated. Please verify before relying on the results." -f $healthCheckerVersion)
    }
}