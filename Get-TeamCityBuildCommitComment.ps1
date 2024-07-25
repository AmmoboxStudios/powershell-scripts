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

$ChangeUrls = $response.changes.change.href
$Comments = @()

$Comments += foreach ($ChangeUrl in $ChangeUrls) {
    $Url = $TeamCityUrl + $ChangeUrl

    try {
        $Response = Invoke-RestMethod -Uri $Url -Method 'GET' -Headers $headers -ErrorAction 'Stop'
    }
    catch {
        Write-Error "Error: $_"
    }

    $Response.change.comment
}

Set-Content -Path comments.txt -Value $Comments