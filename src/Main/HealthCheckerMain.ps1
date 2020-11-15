Function HealthCheckerMain {

    Set-ScriptLogFileLocation -FileName "HealthCheck" -IncludeServerName $true
    Test-RequiresServerFqdn
    Write-HealthCheckerVersion
    [HealthChecker.HealthCheckerExchangeServer]$HealthObject = Get-HealthCheckerExchangeServer
    $analyzedResults = Start-AnalyzerEngine -HealthServerObject $HealthObject
    Write-ResultsToScreen -ResultsToWrite $analyzedResults.DisplayResults
    $analyzedResults | Export-Clixml -Path $OutXmlFullPath -Encoding UTF8 -Depth 6
    Write-Grey("Output file written to {0}" -f $Script:OutputFullPath)
    Write-Grey("Exported Data Object Written to {0} " -f $Script:OutXmlFullPath)
}