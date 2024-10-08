[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityToken = $env:TeamCityToken,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityUrl = $env:TeamCityUrl,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityBuildId = $env:TeamCityBuildId,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookUrl = $env:DiscordWebhookUrl,
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookContent = "commit-content.json",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $DiscordWebhookFile = $env:DiscordWebhookFile
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
$SvnBranch = $Response.build.branchName
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
    $ChangeUsername = $Change.username
    if ($ChangeUsername -ne 'ariff.a') {
        $Field = @{
            "name"  = $ChangeUsername
            "value" = "[$($Change.version)]($($Change.webUrl))"
        }
    
        $Fields += $Field
    }
}

# Limit the fields to 25 (Discord's field limit per embed)
$Fields = $Fields[0..24]

$Color = 13631488

$Embed = @{
    "title"  = "Rev $SvnRevision on branch $SvnBranch"
    "url"    = $ChangesWebUrl + "?buildTab=changes"
    "color"  = $Color
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

if ($DiscordWebhookFile) { & $PSScriptRoot\Send-DiscordWebhook.ps1 -WebhookUrl $DiscordWebhookUrl -WebhookFile $DiscordWebhookFile }