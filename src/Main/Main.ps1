Function Main {
    
    if(-not (Is-Admin) -and
        (-not $AnalyzeDataOnly -and
        -not $BuildHtmlServersReport))
	{
        Write-Warning "The script needs to be executed in elevated mode. Start the Exchange Management Shell as an Administrator."
        $Script:ErrorStartCount = $Error.Count
		Start-Sleep -Seconds 2;
		exit
    }

    if ($Error.Count -gt 175)
    {
        Write-Verbose("Clearing Error to avoid script issues")
        $Error.Clear()
    }

    $Script:ErrorStartCount = $Error.Count #useful for debugging 
    $Script:ErrorsExcludedCount = 0 #this is a way to determine if the only errors occurred were in try catch blocks. If there is a combination of errors in and out, then i will just dump it all out to avoid complex issues. 
    $Script:ErrorsExcluded = @() 
    $Script:date = (Get-Date)
    $Script:dateTimeStringFormat = $date.ToString("yyyyMMddHHmmss")
    
    if($BuildHtmlServersReport)
    {
        Set-ScriptLogFileLocation -FileName "HealthChecker-HTMLServerReport"
        $files = Get-HealthCheckFilesItemsFromLocation
        $fullPaths = Get-OnlyRecentUniqueServersXMLs $files
        $importData = Import-MyData -FilePaths $fullPaths
        Create-HtmlServerReport -AnalyzedHtmlServerValues $importData.HtmlServerValues
        sleep 2;
        return
    }

    if((Test-Path $OutputFilePath) -eq $false)
    {
        Write-Host "Invalid value specified for -OutputFilePath." -ForegroundColor Red
        return 
    }

    if($LoadBalancingReport)
    {
        LoadBalancingMain
        return
    }

    if($DCCoreRatio)
    {
        $oldErrorAction = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        try 
        {
            Get-ExchangeDCCoreRatio
            return
        }
        finally
        {
            $ErrorActionPreference = $oldErrorAction
        }
    }

	if($MailboxReport)
	{
        Set-ScriptLogFileLocation -FileName "HealthCheck-MailboxReport" -IncludeServerName $true 
        Get-MailboxDatabaseAndMailboxStatistics
        Write-Grey("Output file written to {0}" -f $Script:OutputFullPath)
        return
    }

    if ($AnalyzeDataOnly)
    {
        Set-ScriptLogFileLocation -FileName "HealthChecker-Analyzer"
        $files = Get-HealthCheckFilesItemsFromLocation
        $fullPaths = Get-OnlyRecentUniqueServersXMLs $files
        $importData = Import-MyData -FilePaths $fullPaths

        $analyzedResults = @()
        foreach ($serverData in $importData)
        {
            $analyzedServerResults = Start-AnalyzerEngine -HealthServerObject $serverData.HealthCheckerExchangeServer
            Write-ResultsToScreen -ResultsToWrite $analyzedServerResults.DisplayResults
            $analyzedResults += $analyzedServerResults
        }

        Create-HtmlServerReport -AnalyzedHtmlServerValues $analyzedResults.HtmlServerValues
        return
    }

	HealthCheckerMain
}

try 
{
    $Script:Logger = New-LoggerObject -LogName "HealthChecker-Debug" -LogDirectory $OutputFilePath -VerboseEnabled $true -EnableDateTime $false -ErrorAction SilentlyContinue
    Main
}
finally 
{
    Get-ErrorsThatOccurred
    if($Script:VerboseEnabled)
    {
        $Host.PrivateData.VerboseForegroundColor = $VerboseForeground
    }
    $Script:Logger.RemoveLatestLogFile()
    if($Script:Logger.PreventLogCleanup)
    {
        Write-Host("Output Debug file written to {0}" -f $Script:Logger.FullPath)
    }
}
