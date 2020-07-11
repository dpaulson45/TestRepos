Write-Host "Hello World"

<#
if ($false)
{
    #testing failing only way to exit and get a fail is to do exit 1
    exit 1
}
#>
#Create Release Notes

$env:Testing = (Get-FileHash -Algorithm SHA256 ".\Test-Script\TestScript.ps1").Hash
