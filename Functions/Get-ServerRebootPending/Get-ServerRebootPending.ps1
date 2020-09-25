Function Get-ServerRebootPending {
[CmdletBinding()]
param(
[Parameter(Mandatory=$true)][string]$ServerName,
[Parameter(Mandatory=$false)][scriptblock]$CatchActionFunction
)
#Function Version 1.1
<# 
Required Functions: 
    https://raw.githubusercontent.com/dpaulson45/PublicPowerShellScripts/master/Functions/Write-VerboseWriters/Write-VerboseWriter.ps1
    https://raw.githubusercontent.com/dpaulson45/PublicPowerShellScripts/master/Functions/Invoke-ScriptBlockHandler/Invoke-ScriptBlockHandler.ps1
#>
Function Get-PendingFileReboot {
    try 
    {
        if((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\" -Name PendingFileRenameOperations -ErrorAction Stop))
        {
            return $true 
        }
        return $false
    }
    catch 
    {
        throw 
    }
}
Function Get-PendingSCCMReboot {
    try 
    {
        $sccmReboot = Invoke-CimMethod -Namespace 'Root\ccm\clientSDK' -ClassName 'CCM_ClientUtilities' -Name 'DetermineIfRebootPending' -ErrorAction Stop 
        return $sccmReboot
    }
    catch 
    {
        throw 
    }
}
Function Get-PathTestingReboot {
param(
[string]$TestingPath 
)
    if(Test-Path $TestingPath)
    {
        return $true 
    }
    else 
    {
        return $false 
    }
}

Write-VerboseWriter("Calling: Get-ServerRebootPending")
$pendingFileRenameOperationValue = Invoke-ScriptBlockHandler -ComputerName $ServerName -ScriptBlock ${Function:Get-PendingFileReboot} -ScriptBlockDescription "Get-PendingFileReboot" -CatchActionFunction $CatchActionFunction
if($pendingFileRenameOperationValue -eq $null)
{
    $pendingFileRenameOperationValue = $false
}
$serverPendingReboot = New-Object PSCustomObject
$serverPendingReboot | Add-Member -MemberType NoteProperty -Name "PendingFileRenameOperations" -Value $pendingFileRenameOperationValue
$serverPendingReboot | Add-Member -MemberType NoteProperty -Name "SccmReboot" -Value (Invoke-ScriptBlockHandler -ComputerName $ServerName -ScriptBlock ${Function:Get-PendingSCCMReboot} -ScriptBlockDescription "Get-PendingSCCMReboot" -CatchActionFunction $CatchActionFunction)
$serverPendingReboot | Add-Member -MemberType NoteProperty -Name "ComponentBasedServicingPendingReboot" -Value (Invoke-ScriptBlockHandler -ComputerName $ServerName -ScriptBlock ${Function:Get-PathTestingReboot} -ScriptBlockDescription "Get-PendingAutoUpdateReboot" -CatchActionFunction $CatchActionFunction -ArgumentList "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending")
$serverPendingReboot | Add-Member -MemberType NoteProperty -Name "AutoUpdatePendingReboot" -Value (Invoke-ScriptBlockHandler -ComputerName $ServerName -ScriptBlock ${Function:Get-PathTestingReboot} -ScriptBlockDescription "Get-PendingAutoUpdateReboot" -CatchActionFunction $CatchActionFunction -ArgumentList "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
$serverPendingReboot | Add-Member -MemberType NoteProperty -Name "SccmRebootPending" -Value ($serverPendingReboot.SccmReboot -and ($serverPendingReboot.SccmReboot.RebootPending -or $serverPendingReboot.SccmReboot.IsHardRebootPending))
$serverPendingReboot | Add-Member -MemberType NoteProperty -Name "PendingReboot" -Value ($serverPendingReboot.PendingFileRenameOperations -or $serverPendingReboot.ComponentBasedServicingPendingReboot -or $serverPendingReboot.AutoUpdatePendingReboot -or $serverPendingReboot.SccmRebootPending)
return $serverPendingReboot 
}