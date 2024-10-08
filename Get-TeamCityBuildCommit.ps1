[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityToken = $env:TeamCityToken,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityUrl = $env:TeamCityUrl,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityBuildId = $env:TeamCityBuildId,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookColor = $env:DiscordWebhookColor,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookUrl = $env:DiscordWebhookUrl,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookContent = $env:DiscordWebhookContent,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookFile = $env:DiscordWebhookFile
)

function Invoke-TeamCityApi {
    param (
        [string]$Url
    )

    $Headers = @{
        "Authorization" = "Bearer $TeamCityToken"
        "Content-Type"  = "application/json"
    }
    
    try {
        return Invoke-RestMethod -Uri $Url -Method 'GET' -Headers $Headers -ErrorAction 'Stop'
    }
    catch {
        Write-Error "Error fetching from $Url : $_"
        return $null
    }
}

# Set the TeamCity server URL and API endpoint for Builds
$BuildEndpoint = "/app/rest/builds/$TeamCityBuildId"
$BuildUrl = $TeamCityUrl + $BuildEndpoint
$BuildResponse = Invoke-TeamCityApi -Url $BuildUrl
if (-not $BuildResponse) { return }

$ChangesWebUrl = $BuildResponse.build.webUrl
$SvnBranch = $BuildResponse.build.branchName
$SvnRevision = $BuildResponse.build.revisions.revision | Where-Object vcsBranchName -ne 'refs/heads/main' | ForEach-Object version

# Set the TeamCity server URL and API endpoint for Changes
$ChangesUrl = $TeamCityUrl + $BuildResponse.build.changes.href
$ChangesResponse = Invoke-TeamCityApi -Url $ChangesUrl
if (-not $ChangesResponse) { return }

$Fields = @()

$Fields = $ChangesResponse.changes.change | Where-Object username -ne 'ariff.a' | ForEach-Object {
    @{
        "name"  = $_.username
        "value" = "[$($_.version)]($($_.webUrl))"
    }
}

# Limit the fields to 25 (Discord's field limit per embed)
$Fields = $Fields | Select-Object -First 25
$Embed = @{
    "title"  = "Svn Rev: $SvnRevision | Branch: $SvnBranch"
    "url"    = $ChangesWebUrl + "?buildTab=changes"
    "color"  = $DiscordWebhookColor
    "fields" = $Fields
}
$Content = "Potential commits failing build"
$Payload = @{
    "content"     = $Content
    "embeds"      = @($Embed)
    "attachments" = @()
}

$PayloadJson = $Payload | ConvertTo-Json -Depth 4
$PayloadJson
Set-Content $DiscordWebhookContent -Value $PayloadJson -Force

& $PSScriptRoot\Send-DiscordWebhook.ps1 -WebhookUrl $DiscordWebhookUrl -WebhookContent $DiscordWebhookContent

# Set the TeamCity server URL and API endpoint for Artifacts
$ArtifactsEndpoint = "/app/rest/builds/$TeamCityBuildId/artifacts"
$ArtifactsUrl = $TeamCityUrl + $ArtifactsEndpoint
$ArtifactsResponse = Invoke-TeamCityApi -Url $ArtifactsUrl
if (-not $ArtifactsResponse) { return }

# Set the TeamCity server URL and API endpoint for Artifact
$ArtifactUrl = $TeamCityUrl + $ArtifactsResponse.files.file.children.href
$ArtifactResponse = Invoke-TeamCityApi -Url $ArtifactUrl
if (-not $ArtifactResponse) { return }

# Set the TeamCity server URL and API endpoint for Content
$ContentUrl = $TeamCityUrl + $ArtifactResponse.files.file.content.href
$ContentResponse = Invoke-TeamCityApi -Url $ContentUrl
if (-not $ContentResponse) { return }

$DiscordWebhookFile = $ArtifactResponse.files.file.name
Set-Content -Value $ContentResponse -Path $DiscordWebhookFile

& $PSScriptRoot\Send-DiscordWebhook.ps1 -WebhookUrl $DiscordWebhookUrl -WebhookFile $DiscordWebhookFile