[CmdletBinding()]
param (
  [string][Parameter(ParameterSetName = "DefaultSet")]
  [string]$ConfigFilePath = $env:ConfigFilePath,
  [string][Parameter(ParameterSetName = "DefaultSet")]
  [string]$PlayFabTitleId = $env:PlayFabTitleId,
  [string][Parameter(ParameterSetName = "DefaultSet")]
  [string]$PlayFabDevKey = $env:PlayFabDevKey
)

$FileContent = Get-Content -Path $filePath -Raw
$FileContent = $FileContent -replace "\[SERVICE_TITLE_ID\]", $PlayFabTitleId
$FileContent = $FileContent -replace "\[SERVICE_DEV_KEY\]", $PlayFabDevKey

Set-Content -Path $ConfigFilePath -Value $FileContent

Write-Host "$ConfigFilePath replaced successfully!"
