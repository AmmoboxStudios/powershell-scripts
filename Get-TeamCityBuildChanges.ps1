[CmdletBinding()]
param (
  [Parameter(ParameterSetName = 'DefaultSet')]
  [string]$TeamCityUrl,
  [Parameter(ParameterSetName = 'DefaultSet')]
  [string]$TeamCityToken,
  [Parameter(ParameterSetName = 'DefaultSet')]
  [string]$BuildLocator
)

function Invoke-TeamCityRestMethod {
    param(
        [string]$Url,
        [string]$Token,
        [string]$Method = "GET",
        [string]$Body = $null
    )

    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -ErrorAction Stop
        return $response
    }
    catch {
        Write-Error "Error: $_"
        return $null
    }
}

$buildEndpoint = "/app/rest/builds/$BuildLocator"

$fullUrl = $TeamCityUrl + $buildEndpoint
$response = Invoke-TeamCityRestMethod -Url $fullUrl -Token $TeamCityToken
$changesUrl = $TeamCityUrl + $response.build.changes.href

$response = Invoke-TeamCityRestMethod -Url $changesUrl -Token $TeamCityToken
$changes = $response.changes.change 
$usernames = $changes | Select-Object username -Unique | ForEach-Object username

if(!(Test-Path "$PSScriptRoot\$BuildLocator")) {
    New-Item -ItemType Directory "$PSScriptRoot\$BuildLocator" | Out-Null
}

foreach ($username in $usernames) {
    $changes | Where-Object username -eq $username | Select-Object @{N="SvnRevision";E={$_.version}}, webUrl
}



