[CmdletBinding()]
param (
  [string][Parameter(ParameterSetName = "DefaultSet")]
  [string]$WebhookUrl = $env:WebhookUrl,
  [string][Parameter(ParameterSetName = "DefaultSet")]
  [string]$WebhookContent = $env:WebhookContent,
  [string][Parameter(ParameterSetName = "DefaultSet")]
  [string]$WebhookFile = $env:WebhookFile
)

if (-not ([string]::IsNullOrEmpty($WebhookFile))) { 
  curl.exe -F "file1=@$WebhookFile" $WebhookUrl 
  Write-Output "Webhook successfully sent."
  exit 0
}

try { $WebhookContent | ConvertFrom-Json } catch { $WebhookContent = Get-Content $WebhookContent -Raw }

try {
  Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $WebhookContent -ContentType 'application/json' -ErrorAction Stop

  Write-Output "Webhook successfully sent."
}
catch {
  Write-Error "Error sending webhook: $_"
}