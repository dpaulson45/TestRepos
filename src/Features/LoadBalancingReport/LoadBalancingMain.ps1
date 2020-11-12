Function LoadBalancingMain {

    Set-ScriptLogFileLocation -FileName "LoadBalancingReport" 
    Write-HealthCheckerVersion
    Write-Green("Client Access Load Balancing Report on " + $date)
    Get-CASLoadBalancingReport
    Write-Grey("Output file written to " + $OutputFullPath)
    Write-Break
    Write-Break

}