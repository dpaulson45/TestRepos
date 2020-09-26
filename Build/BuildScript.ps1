$excludeList = @("Update-FunctionToScript.ps1","Test-Script.ps1","New-FunctionTemplate.ps1")
$assets = Get-ChildItem ..\Scripts -Recurse | ?{($_.Name.ToString().EndsWith(".ps1") -or $_.Name.ToString().EndsWith(".config")) -and (!$excludeList.Contains($_.Name.ToString()))}

$returnHash = @{}
foreach($file in $assets)
{
    $hashValue = (Get-FileHash -Algorithm SHA256 $file.VersionInfo.FileName).Hash
    $obj = New-Object PSCustomObject
    $obj | Add-Member -MemberType NoteProperty -Name "FileName" -Value $file.Name
    $obj | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hashValue

    $returnHash.Add($file.Name, $obj)

    Write-Host("FileName: {0} Hash: {1}" -f $obj.FileName, $obj.Hash)
}

return $returnHash