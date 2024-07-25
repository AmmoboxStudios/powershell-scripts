[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityToken = "token",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityUrl = "https://tc.ammoboxstudios.com",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityBuildId = "20595"
)

$headers = @{
    "Authorization" = "Bearer $TeamCityToken"
    "Content-Type"  = "application/json"
}

# Set the TeamCity server URL and API endpoint for Builds
$BuildEndpoint = "/app/rest/builds/$TeamCityBuildId"

$BuildUrl = $TeamCityUrl + $BuildEndpoint

try {
    $Response = Invoke-RestMethod -Uri $BuildUrl -Method 'GET' -Headers $headers -ErrorAction 'Stop'
}
catch {
    Write-Error "Error: $_"
}

# Set the TeamCity server URL and API endpoint for Changes
$ChangesUrl = $TeamCityUrl + $response.build.changes.href

try {
    $Response = Invoke-RestMethod -Uri $ChangesUrl -Method 'GET' -Headers $headers -ErrorAction 'Stop'
}
catch {
    Write-Error "Error: $_"
}

$Changes = $Response | ForEach-Object changes | ForEach-Object change | Select-Object @{N="Usernames";E={"$($_.username): [$($_.version)]($($_.webUrl))"}}
$Usernames = $Changes | ForEach-Object Usernames
Set-Content -Path usernames.txt -Value $Usernames