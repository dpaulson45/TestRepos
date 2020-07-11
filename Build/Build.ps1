Write-Host "Hello World"

<#
if ($false)
{
    #testing failing only way to exit and get a fail is to do exit 1
    exit 1
}
#>
#Create Release Notes

$outputText = @"
SHA256: {0}

How to Verify Hash Value: https://github.com/dpaulson45/HealthChecker/wiki/How-to-Verify-Hash-Value
"@ -f ((Get-FileHash -Algorithm SHA256 ".\Test-Script\TestScript.ps1").Hash)

$outputText  > .\Build\ReleaseNotes.txt