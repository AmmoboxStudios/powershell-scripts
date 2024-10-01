[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$WebhookUrl,
  [Parameter(Mandatory = $false)]
  [string]$WebhookContent,
  [Parameter(Mandatory = $false)]
  [string]$File
)

if (-not ([string]::IsNullOrEmpty($file))) { 
  curl.exe -F "file1=@$File" $WebhookUrl 
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