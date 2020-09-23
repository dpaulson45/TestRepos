Param(
[string]$url
)

$webRequest = Invoke-WebRequest $url

$json = ConvertFrom-Json -InputObject $webRequest.Content

$tagString = $json[0].tag_name

Write-Host("Current tag: {0}" -f $tagString)
$split = $tagString.Split(".")
$tagReturn = "v1.{0}.{1}" -f $split[-2], (++([double]$split[-1]))
Write-Host("New tag: {0}" -f $tagReturn)
return $tagReturn