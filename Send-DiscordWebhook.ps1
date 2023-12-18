[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$WebhookUrl,
  [Parameter(Mandatory)]
  [string]$WebhookContent
)

try {
  Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $WebhookContent -ContentType 'application/json' -ErrorAction Stop

  Write-Output "Webhook successfully sent."
}
catch {
  Write-Error "Error sending webhook: $_"
}