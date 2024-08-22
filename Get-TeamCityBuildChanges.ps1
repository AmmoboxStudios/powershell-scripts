[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityToken = "token",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityUrl = "https://tc.ammoboxstudios.com",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityBuildId = "21776"
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

$BuildResponse = $Response.build
$BuildNumber = $BuildResponse.number

if ($BuildNumber -ne 'N/A') {
    $BuildStatus = $BuildResponse.status
}
else {
    $BuildStatus = $BuildNumber
}

if ($BuildStatus -eq 'FAILURE') {
    $BuildChangesUrl = $BuildResponse.changes.href

    $BuildChangesUrl = $TeamCityUrl + $BuildChangesUrl

    try {
        $Response = Invoke-RestMethod -Uri $BuildChangesUrl -Method 'GET' -Headers $headers -ErrorAction 'Stop'
    }
    catch {
        Write-Error "Error: $_"
    }

    $Response
}

