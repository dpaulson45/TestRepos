$excludeList = @("Update-FunctionToScript.ps1","Test-Script.ps1","New-FunctionTemplate.ps1")
$assets = Get-ChildItem .\Scripts -Recurse | ?{($_.Name.ToString().EndsWith(".ps1") -or $_.Name.ToString().EndsWith(".config")) -and (!$excludeList.Contains($_.Name.ToString()))}

$returnHash = @{}
foreach($file in $assets)
{
    $hashValue = (Get-FileHash -Algorithm SHA256 $file.VersionInfo.FileName).Hash
    $obj = New-Object PSCustomObject
    $obj | Add-Member -MemberType NoteProperty -Name "FileName" -Value $file.Name
    $obj | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hashValue
    $obj | Add-Member -MemberType NoteProperty -Name "FilePath" -Value $file.VersionInfo.FileName

    $returnHash.Add($file.Name, $obj)
}
#Test Change
return $returnHash