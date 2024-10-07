[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityToken = $env:TeamCityToken,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityUrl = $env:TeamCityUrl,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityBuildId = $env:TeamCityBuildId,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookUrl = $env:DiscordWebhookUrl
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
    return
}

$ChangesWebUrl = $Response.build.webUrl
$SvnRevision = $Response.build.revisions.revision | Where-Object vcsBranchName -ne 'refs/heads/main' | ForEach-Object version
$ChangesUrl = $TeamCityUrl + $Response.build.changes.href

try {
    $ChangesResponse = Invoke-RestMethod -Uri $ChangesUrl -Method 'GET' -Headers $headers -ErrorAction 'Stop'
}
catch {
    Write-Error "Error: $_"
    return
}

$Fields = @()

foreach ($Change in $ChangesResponse.changes.change) {
    $Field = @{
        "name"  = $Change.username
        "value" = "[$($Change.version)]($($Change.webUrl))"
    }

    $Fields += $Field
}

# Limit the fields to 25 (Discord's field limit per embed)
$Fields = $Fields[0..24]

$Embed = @{
    "title" = "Potential commits failing build (Revision: $SvnRevision)"
    "url"   = $ChangesWebUrl + "?buildTab=changes"
    "color" = 16734296
    "fields" = $Fields
}

$Payload = @{
    "content" = $null
    "embeds"  = @($Embed)
    "attachments" = @()
}

$JsonFile = ".\commit-content.json"
$PayloadJson = $Payload | ConvertTo-Json -Depth 4
Set-Content $JsonFile -Value $PayloadJson -Force

Write-Output "commit-content.json"
Get-Content $JsonFile

.\Send-DiscordWebhook.ps1 -WebhookUrl $DiscordWebhookUrl -WebhookContent $JsonFile