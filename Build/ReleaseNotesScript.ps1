$outputText = @"
SHA256: {0}

How to Verify Hash Value: https://github.com/dpaulson45/HealthChecker/wiki/How-to-Verify-Hash-Value
"@ -f ((Get-FileHash -Algorithm SHA256 ".\Test-Script\TestScript.ps1").Hash)

Write-Host $outputText