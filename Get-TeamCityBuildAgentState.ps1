[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityToken = "token",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityUrl = "https://tc.ammoboxstudios.com",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $TeamCityAgent = "TeamCityAgent"
)

$headers = @{
    "Authorization" = "Bearer $TeamCityToken"
    "Content-Type"  = "application/json"
}

# Set the TeamCity server URL and API endpoint for agents
$AgentsEndpoint = "/app/rest/agents"

$BuildUrl = $TeamCityUrl + $AgentsEndpoint

try {
    $Response = Invoke-RestMethod -Uri $BuildUrl -Method 'GET' -Headers $headers -ErrorAction 'Stop'
}
catch {
    Write-Error "Error: $_"
}

$AgentResponse = $Response.agents.agent | Where-Object name -eq $TeamCityAgent
$AgentEndpoint = $AgentResponse.href

$AgentUrl = $TeamCityUrl + $AgentEndpoint

try {
    $Response = Invoke-RestMethod -Uri $AgentUrl -Method 'GET' -Headers $headers -ErrorAction 'Stop'
}
catch {
    Write-Error "Error: $_"
}

$AgentState = $Response.agent.build.state

if ($null -eq $AgentResponse) {
    $AgentState = "doesn't exist"
} elseif ($null -eq $AgentState) {
    $AgentState = "is idle"
}

Write-Output "$TeamCityAgent $AgentState"
