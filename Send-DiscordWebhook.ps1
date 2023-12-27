[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$WebhookUrl,
  [Parameter(Mandatory)]
  [string]$WebhookContent
)

try { $WebhookContent | ConvertFrom-Json } catch { $WebhookContent = Get-Content $WebhookContent -Raw }

try {
  Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $WebhookContent -ContentType 'application/json' -ErrorAction Stop

  Write-Output "Webhook successfully sent."
}
catch {
  Write-Error "Error sending webhook: $_"
}