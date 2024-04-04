[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$awsProfile,
  [Parameter(Mandatory)]
  [string]$awsRegion,
  [Parameter(Mandatory)]
  [string]$folderPath
)

Start-Transcript -Path .\update.log

$items = Get-ChildItem -Path $folderPath -Filter "*.csv"

foreach ($item in $items) {
  $data = Import-Csv $item.FullName

  foreach ($row in $data) {
    $envVariables = @{}

    foreach ($key in $row.PSObject.Properties.Name) {
      if ($key -ne 'FunctionName') {
        $envVariables[$key] = $row.$key
      }
    }

    $envString = ($envVariables.GetEnumerator() | ForEach-Object { "{0}={1}" -f $_.Key, $_.Value }) -join ','

    # Write-Output "update $($row.FunctionName) env with `n$envString"

    $command = "aws lambda update-function-configuration --function-name $($row.FunctionName) --environment `"Variables={$envString}`" --profile $awsProfile --region $awsRegion | Out-Null"

    Invoke-Expression $command 2>&1

    if ($LASTEXITCODE -ne 0) {
      Write-Output "Error updating function $($row.FunctionName)"
    }

  }
}

Stop-Transcript