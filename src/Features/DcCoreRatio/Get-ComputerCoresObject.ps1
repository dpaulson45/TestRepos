Function Get-ComputerCoresObject {
    param(
    [Parameter(Mandatory=$true)][string]$Machine_Name
    )
        Write-VerboseOutput("Calling: Get-ComputerCoresObject")
        Write-VerboseOutput("Passed: {0}" -f $Machine_Name)
    
        $returnObj = New-Object pscustomobject 
        $returnObj | Add-Member -MemberType NoteProperty -Name Error -Value $false
        $returnObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Machine_Name
        $returnObj | Add-Member -MemberType NoteProperty -Name NumberOfCores -Value ([int]::empty)
        $returnObj | Add-Member -MemberType NoteProperty -Name Exception -Value ([string]::empty)
        $returnObj | Add-Member -MemberType NoteProperty -Name ExceptionType -Value ([string]::empty)
        try 
        {
            $wmi_obj_processor = Get-WmiObjectHandler -ComputerName $Machine_Name -Class "Win32_Processor" -CatchActionFunction ${Function:Invoke-CatchActions}
    
            foreach($processor in $wmi_obj_processor)
            {
                $returnObj.NumberOfCores +=$processor.NumberOfCores
            }
            
            Write-Grey("Server {0} Cores: {1}" -f $Machine_Name, $returnObj.NumberOfCores)
        }
        catch 
        {
            Invoke-CatchActions
            $thisError = $Error[0]
            if($thisError.Exception.Gettype().FullName -eq "System.UnauthorizedAccessException")
            {
                Write-Yellow("Unable to get processor information from server {0}. You do not have the correct permissions to get this data from that server. Exception: {1}" -f $Machine_Name, $thisError.ToString())
            }
            else 
            {
                Write-Yellow("Unable to get processor information from server {0}. Reason: {1}" -f $Machine_Name, $thisError.ToString())
            }
            $returnObj.Exception = $thisError.ToString() 
            $returnObj.ExceptionType = $thisError.Exception.Gettype().FullName
            $returnObj.Error = $true
        }
        
        return $returnObj
    }
    